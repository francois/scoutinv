class Product < ApplicationRecord
  include HasSlug

  has_many_attached :images

  belongs_to :group
  has_many :reservations,       dependent: :delete_all, autosave: true
  has_many :product_categories, dependent: :delete_all, autosave: true
  has_many :notes,              dependent: :delete_all, autosave: true, as: :parent
  has_many :domain_events,      dependent: :delete_all, autosave: true, as: :model
  has_many :categories,         dependent: :delete_all, autosave: true,              through: :product_categories

  scope :by_name, ->{ order(Arel.sql("LOWER(#{quoted_table_name}.name), #{quoted_table_name}.id")) }
  scope :search, ->(string){ where("POSITION(? IN LOWER(#{quoted_table_name}.name || ' ' || COALESCE(#{quoted_table_name}.description, ''))) > 0", string) }
  scope :with_reservations, ->{ includes(reservations: :event) }
  scope :with_categories, ->{ includes(:categories) }
  scope :in_category, ->(category){ includes(:categories).where(categories: { slug: category.slug }) }
  scope :not_recently_reserved, ->{ joins("LEFT JOIN reservations ON reservations.product_id = products.id").where("reservations.created_at IS NULL OR reservations.created_at < ?", 12.months.ago).order(Arel.sql("random()")) }

  validates :name, presence: true, length: { minimum: 2 }

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
    domain_events << ProductNameChanged.new(data: {product_slug: slug, name: name, description: description}, metadata: metadata)       if name_changed? || description_changed?
    domain_events << ProductLocationChanged.new(data: {product_slug: slug, aisle: aisle, shelf: shelf, unit: unit}, metadata: metadata) if aisle_changed? || shelf_changed? || unit_changed?
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
    [aisle, shelf, unit, name, id].map(&:to_s).join(":")
  end
end
