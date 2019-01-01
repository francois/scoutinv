class Consumable < ApplicationRecord
  include HasSlug

  has_many_attached :images

  belongs_to :group
  has_many :consumable_categories, dependent: :delete_all, autosave: true
  has_many :notes,                 dependent: :delete_all, autosave: true, as: :parent
  has_many :domain_events,         dependent: :delete_all, autosave: true, as: :model
  has_many :categories,            dependent: :delete_all, autosave: true,              through: :consumable_categories

  scope :by_name,         ->{ order(Arel.sql("LOWER(#{quoted_table_name}.name), #{quoted_table_name}.id")) }
  scope :with_categories, ->{ includes(:categories) }
  scope :in_category,     ->(category){ includes(:categories).where(categories: { slug: category.slug }) }
  scope :search, ->(string){
    vector = "to_tsvector('fr', coalesce(consumables.name, '') || ' ' || coalesce(consumables.description, '') || ' ' || coalesce(consumables.building, ' ') || ' ' || coalesce(consumables.aisle, ' ') || ' ' || coalesce(consumables.shelf, ' ') || ' ' || coalesce(consumables.unit, ' '))"
    query = "plainto_tsquery('fr', :string)"
    where("#{vector} @@ #{query}", string: string).order(Arel.sql("ts_rank(#{vector}, #{query.sub(":string", Product.connection.quote(string))})"))
  }

  composed_of :base_quantity, class_name: "Quantity", mapping: [%w(base_quantity_value value), %w(base_quantity_si_prefix si_prefix), %w(base_quantity_unit unit)],
    constructor: ->(value, si_prefix, unit){ Quantity.new(value, si_prefix, unit) }

  validates :name, presence: true, length: { minimum: 2 }

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
end
