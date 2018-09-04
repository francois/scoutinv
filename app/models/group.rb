class Group < ApplicationRecord
  include HasSlug

  has_many :products,      dependent: :delete_all, autosave: true
  has_many :events,        dependent: :delete_all, autosave: true
  has_many :members,       dependent: :delete_all, autosave: true
  has_many :domain_events, dependent: :delete_all, autosave: true, as: :model
  has_many :instances,     through: :products

  validates :name, presence: true, length: { minimum: 2 }

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
end
