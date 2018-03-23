class Product < ApplicationRecord
  include HasSlug

  belongs_to :group
  has_many :reservations

  scope :with_reservations, ->{ includes(reservations: :event) }

  validates :name, presence: true, length: { minimum: 2 }
end
