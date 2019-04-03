class Group < ApplicationRecord
  include HasSlug

  has_one_attached :logo

  has_many :troops,        dependent: :delete_all, autosave: true
  has_many :products,      dependent: :delete_all, autosave: true
  has_many :consumables,   dependent: :delete_all, autosave: true
  has_many :events,        dependent: :delete_all, autosave: true
  has_many :members,       dependent: :delete_all, autosave: true
  has_many :domain_events, dependent: :delete_all, autosave: true, as: :model
  has_many :instances,     through: :products
  has_many :reservations,  through: :instances

  validates :name, presence: true, length: { minimum: 2 }

  def has_logo?
    logo.attachment.present?
  end

  def inventory_directors
    members.select(&:inventory_director?)
  end

  def accountants
    members.select(&:accountant?)
  end

  def find_note_by_slug!(slug)
    notes = Note.find_by_sql(find_note_by_slug_sql(slug))

    raise ActiveRecord::RecordNotFound if notes.empty?
    notes.first
  end

  def register_new_troop(attributes, metadata: {})
    troops.build(attributes).tap do |new_troop|
      domain_events << TroopRegistered.new(
        data: {
          name: new_troop.name,
        },
        metadata: metadata
      )
    end
  end

  def register_new_event(attributes, metadata: {})
    events.build(attributes).tap do |new_event|
      domain_events << EventRegistered.new(
        data: {
          description: new_event.description,
          end_on: new_event.end_on,
          event_slug: new_event.slug,
          group_slug: slug,
          start_on: new_event.start_on,
          title: new_event.title,
        },
        metadata: metadata
      )
    end
  end

  def register_new_product(attributes, metadata: {})
    products.build(attributes).tap do |new_product|
      domain_events << ProductRegistered.new(
        data: {
          aisle: new_product.aisle,
          building: new_product.building,
          categories: new_product.categories.map(&:name),
          description: new_product.description,
          group_slug: self.slug,
          name: new_product.name,
          product_slug: new_product.slug,
          shelf: new_product.shelf,
          unit: new_product.unit,
        },
        metadata: metadata
      )
    end
  end

  def register_new_consumable(attributes, metadata: {})
    consumables.build(attributes).tap do |new_consumable|
      domain_events << ConsumableRegistered.new(
        data: {
          aisle: new_consumable.aisle,
          building: new_consumable.building,
          categories: new_consumable.categories.map(&:name),
          description: new_consumable.description,
          group_slug: self.slug,
          name: new_consumable.name,
          consumable_slug: new_consumable.slug,
          shelf: new_consumable.shelf,
          unit: new_consumable.unit,
        },
        metadata: metadata
      )
    end
  end

  def register_new_member(attributes, metadata: {})
    members.build(name: attributes.fetch(:name), email: attributes.fetch(:email)).tap do |new_member|
      domain_events << MemberRegistered.new(
        data: {
          email: new_member.email,
          group_slug: self.slug,
          name: new_member.name,
          user_slug:  new_member.slug,
        },
        metadata: metadata
      )
    end
  end

  def convert_product_to_consumable(product_slug, reason, metadata)
    product = products.detect{|product| product.slug == product_slug}
    raise ActiveRecord::RecordNotFound, "Could not find product with slug #{product_slug.inspect}" unless product

    attributes = {
      group: product.group,
      name: product.name,
      description: product.description,
      slug: product.slug,
      aisle: product.aisle,
      shelf: product.shelf,
      unit: product.unit,
      building: product.building,
      internal_unit_price: product.internal_unit_price,
      external_unit_price: product.external_unit_price,

      base_quantity: QuantityParser.new.parse("1 unit"),
    }

    register_new_consumable(attributes, metadata: metadata).tap do |consumable|
      consumable.categories = product.categories
      product.images.detach.each do |image|
        consumable.images.attach(image.blob)
      end if product.images.detach&.any?

      quantity = QuantityParser.new.parse("#{product.available_quantity} unit")
      consumable.change_quantity(quantity, unit_price: 0, reason: reason)
      product.destroy

      domain_events << ProductConvertedToConsumable.new(
        data: {
          group_slug: self.slug,
          product_slug: slug,
        },
        metadata: metadata
      )
    end
  end

  private

  def find_note_by_slug_sql(slug)
    <<~EOSQL.squish.gsub(":quoted_slug", Note.connection.quote(slug)).gsub(":quoted_group_id", Note.connection.quote(id))
      SELECT notes.*
      FROM notes
      JOIN events ON events.id = notes.parent_id AND notes.parent_type = 'Event'
      WHERE notes.slug = :quoted_slug
        AND events.group_id = :quoted_group_id

      UNION

      SELECT notes.*
      FROM notes
      JOIN products ON products.id = notes.parent_id AND notes.parent_type = 'Product'
      WHERE notes.slug = :quoted_slug
        AND products.group_id = :quoted_group_id
    EOSQL
  end
end
