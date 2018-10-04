class Product < ApplicationRecord
  include HasSlug

  has_many_attached :images

  belongs_to :group
  has_many :product_categories, dependent: :delete_all, autosave: true
  has_many :notes,              dependent: :delete_all, autosave: true, as: :parent
  has_many :domain_events,      dependent: :delete_all, autosave: true, as: :model
  has_many :categories,         dependent: :delete_all, autosave: true,              through: :product_categories
  has_many :instances,          dependent: :delete_all, autosave: true
  has_many :reservations,       dependent: :delete_all, autosave: true,              through: :instances

  scope :by_name,               ->{ order(Arel.sql("LOWER(#{quoted_table_name}.name), #{quoted_table_name}.id")) }
  scope :with_reservations,     ->{ includes(reservations: :event) }
  scope :with_categories,       ->{ includes(:categories) }
  scope :with_instances,        ->{ includes(:instances) }
  scope :not_recently_reserved, ->{ joins("LEFT JOIN instances ON instances.product_id = products.id LEFT JOIN reservations ON reservations.instance_id = instances.id").where("reservations.created_at IS NULL OR reservations.created_at < ?", 12.months.ago).order(Arel.sql("random()")) }
  scope :leased,                ->{ includes(:reservations).references(:reservations).where(reservations: {returned_on: nil}).where.not(reservations: {leased_on: nil}) }
  scope :available,             ->{ includes(:reservations, :instances).references(:reservations, :instances).where(instances: {state: "available"}, reservations: {id: nil}) }
  scope :in_category,           ->(category){ includes(:categories).where(categories: { slug: category.slug }) }
  scope :reserved,              ->(on_event=nil){
    if on_event
      includes(:reservations).references(:reservations).where(reservations: {event_id: on_event.id})
    else
      includes(:reservations).references(:reservations).where.not(reservations: {event_id: nil})
    end
  }
  scope :double_booked,         ->(event) {
    select(<<~EOSQL)
              products.*
            , events.id       AS double_booked_event_id
            , events.slug     AS double_booked_event_slug
            , events.title    AS double_booked_event_title
            , events.start_on AS double_booked_event_start_on
            , events.end_on   AS double_booked_event_end_on
            , array_agg(instances.id) AS double_booked_instance_ids
            EOSQL
              .joins("JOIN instances    ON instances.product_id     = products.id".squish)
              .joins("JOIN reservations ON reservations.instance_id = instances.id".squish)
              .joins("JOIN events       ON events.id                = reservations.event_id".squish)
              .where.not(reservations: { event_id: event.id })
              .where("reservations.instance_id IN (SELECT instance_id FROM reservations WHERE event_id = ?)", event.id)
              .where("daterange(events.start_on - 1, events.end_on + 1, '[]') && daterange(date :start_on - 1, date :end_on + 1, '[]')", start_on: event.start_on, end_on: event.end_on)
              .group("products.id", "events.id")
  }
  scope :search, ->(string){
    vector = "to_tsvector('fr', coalesce(products.name, '') || ' ' || coalesce(products.description, '') || ' ' || coalesce(products.building, ' ') || ' ' || coalesce(products.aisle, ' ') || ' ' || coalesce(products.shelf, ' ') || ' ' || coalesce(products.unit, ' '))"
    query = "plainto_tsquery('fr', :string)"
    where("#{vector} @@ #{query}", string: string).order(Arel.sql("ts_rank(#{vector}, #{query.sub(":string", Product.connection.quote(string))})"))
  }

  validates :name, presence: true, length: { minimum: 2 }
  validates :quantity, numericality: { only_integer: true, greater_than: 0, less_than_or_equal: ->(product){ product.categories.map(&:max_quantity).min || 99 } }
  validates :internal_unit_price, :external_unit_price, numericality: { greater_than_or_equal_to: 0, allow_blank: false }

  before_save :manage_instances
  after_touch :update_instances_count

  def unit_price(internal: false)
    internal ? internal_unit_price : external_unit_price
  end

  def has_location?
    building.present? || aisle.present? || shelf.present? || unit.present?
  end

  def location_changed?
    building_changed? || aisle_changed? || shelf_changed? || unit_changed?
  end

  def available_quantity
    instances.select(&:available?).size
  end

  def reserved_quantity_on(date_range)
    instances.select do |instance|
      instance.reserved_on?(date_range)
    end.size
  end

  def add_note(attributes, metadata: {})
    notes.build(attributes).tap do |new_note|
      domain_events << NoteAddedToProduct.new(
        data: {
          author_slug: new_note.author_slug,
          body: new_note.body,
          product_slug: slug,
        },
        metadata: metadata
      )
    end
  end

  def change_data(attributes, metadata: {})
    self.attributes = attributes
    domain_events << ProductNameChanged.new(data: {product_slug: slug, name: name, description: description}, metadata: metadata)                           if name_changed? || description_changed?
    domain_events << ProductLocationChanged.new(data: {product_slug: slug, building: building, aisle: aisle, shelf: shelf, unit: unit}, metadata: metadata) if location_changed?
    # domain_events << ProductCategoriesChanged.new(data: {product_slug: slug, categories: categories.map(&:name)}, metadata: metadata)
  end

  def category_slugs
    categories.map(&:slug)
  end

  def category_slugs=(value)
    self.categories = Category.where(slug: Array(value).reject(&:blank?))
  end

  # Returns a string to be used for ordering a list of products consistently
  #
  # @return [String] The key to use to order this item consistently
  def sort_key_for_display
    [name.downcase, id].map(&:to_s).join(":")
  end

  def sort_key_for_pickup
    [building, aisle, shelf, unit, name, id].map(&:to_s).join(":")
  end

  private

  def manage_instances
    if new_record?
      manage_instances_on_create
    else
      manage_instances_on_update
    end
  end

  def manage_instances_on_create
    quantity.times.each do |n|
      instances.build
    end
  end

  def manage_instances_on_update
    return unless quantity_changed?

    if quantity_was > quantity
      manage_instance_removal
    else
      manage_instance_additions
    end
  end

  def quantity_delta
    (quantity - quantity_was).abs
  end

  def manage_instance_removal
    candidates = instances.select(&:has_no_reservations?)
    candidates.first(quantity_delta).each(&:destroy)
    return if quantity_delta <= candidates.size

    # We have to remove instances that have had reservations
    # This is unfortunate, but we accept it
    instances.reject(&:destroyed?).first(quantity_delta - candidates.size).each(&:destroy)
  end

  def manage_instance_additions
    quantity_delta.times{|n| instances.build }
  end

  def update_instances_count
    update_attribute(:quantity, instances.reload.size)
  end
end
