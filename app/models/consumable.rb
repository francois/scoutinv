class Consumable < ApplicationRecord
  include HasSlug

  has_many_attached :images

  belongs_to :group
  has_many :consumable_categories,   dependent: :delete_all, autosave: true
  has_many :consumable_transactions, dependent: :delete_all, autosave: true
  has_many :notes,                   dependent: :delete_all, autosave: true, as: :parent
  has_many :domain_events,           dependent: :delete_all, autosave: true, as: :model
  has_many :categories,              dependent: :delete_all, autosave: true,              through: :consumable_categories

  scope :by_name,         ->{ order(Arel.sql("UNACCENT(#{quoted_table_name}.name), #{quoted_table_name}.id")) }
  scope :with_categories, ->{ includes(:categories) }
  scope :in_category,     ->(category){ includes(:categories).where(categories: { slug: category.slug }) }
  scope :search, ->(string){
    vector = "to_tsvector('fr', coalesce(consumables.name, '') || ' ' || coalesce(consumables.description, '') || ' ' || coalesce(consumables.building, ' ') || ' ' || coalesce(consumables.aisle, ' ') || ' ' || coalesce(consumables.shelf, ' ') || ' ' || coalesce(consumables.unit, ' '))"
    query = "plainto_tsquery('fr', :string)"
    where("#{vector} @@ #{query}", string: string).order(Arel.sql("ts_rank(#{vector}, #{query.sub(":string", Product.connection.quote(string))})"))
  }

  validates :name, presence: true, length: { minimum: 2 }
  validates :base_quantity_value, presence: true, numericality: { greater_than: 0, only_integer: false }
  validates :base_quantity_si_prefix, presence: true, inclusion: SI::ALL
  validates :base_quantity_unit, presence: true, inclusion: %w( unit pound litre gram ).freeze
  validates :internal_unit_price, :external_unit_price, presence: true, numericality: { greater_than_or_equal_to: 0, allow_blank: false }

  composed_of :base_quantity, class_name: "Quantity", mapping: [%w(base_quantity_value value), %w(base_quantity_si_prefix si_prefix), %w(base_quantity_unit unit)],
    constructor: ->(value, si_prefix, unit){ Quantity.new(value, si_prefix, unit) }

  # Only used to use the ActionView helpers
  # In reality, this attribute is absolutely unused
  attribute :image_url, :string

  def change_data(attributes, metadata: {})
    self.attributes = attributes
    domain_events << ConsumableNameChanged.new(data: {product_slug: slug, name: name, description: description}, metadata: metadata)                           if name_changed? || description_changed?
    domain_events << ConsumableLocationChanged.new(data: {product_slug: slug, building: building, aisle: aisle, shelf: shelf, unit: unit}, metadata: metadata) if location_changed?
    # domain_events << ConsumableCategoriesChanged.new(data: {product_slug: slug, categories: categories.map(&:name)}, metadata: metadata)
  end

  def add_note(attributes, metadata: {})
    notes.build(attributes).tap do |new_note|
      domain_events << NoteAddedToConsumable.new(
        data: {
          author_slug: new_note.author_slug,
          body: new_note.body,
          product_slug: slug,
        },
        metadata: metadata
      )
    end
  end

  def category_slugs
    categories.map(&:slug)
  end

  def category_slugs=(value)
    self.categories = Category.where(slug: Array(value).reject(&:blank?))
  end

  def has_location?
    building.present? || aisle.present? || shelf.present? || unit.present?
  end

  def location_changed?
    building_changed? || aisle_changed? || shelf_changed? || unit_changed?
  end

  def available_quantity
    consumable_transactions.
      reject(&:marked_for_destruction?).
      reject(&:new_record?).
      map(&:quantity).
      inject(zero_quantity, &:+)
  end

  def change_quantity(quantity, reason: nil, event: nil)
    if reason
      consumable_transactions.build(
        quantity: quantity,
        reason: reason,
      )
    else
      ct   = consumable_transactions.detect{|ct| ct.event == event}
      ct ||= consumable_transactions.build(event: event)
      ct.quantity = quantity.scale(-1)
    end
  end

  def quantity_on(event)
    consumable_transactions.
      select{|ct| ct.event == event}.
      map(&:quantity).
      inject(zero_quantity, &:+).
      scale(-1)
  end

  def si_prefix
    base_quantity.si_prefix
  end

  def unit
    base_quantity.unit
  end

  private

  def zero_quantity
    Quantity.zero(unit)
  end
end
