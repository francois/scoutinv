class Product < ApplicationRecord
  include HasSlug

  belongs_to :group
  has_many :reservations

  scope :by_name, ->{ order(Arel.sql("LOWER(name)")) }
  scope :search, ->(string){ where(Arel.sql("POSITION(? IN name || ' ' || COALESCE(description, '')) > 0", string)) }
  scope :with_reservations, ->{ includes(reservations: :event) }

  validates :name, presence: true, length: { minimum: 2 }
end
