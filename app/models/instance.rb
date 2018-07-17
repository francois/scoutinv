class Instance < ApplicationRecord
  include HasSlug

  belongs_to :product
  has_many :reservations, dependent: :delete_all, autosave: true

  validates :product, :serial_no, :slug, presence: true
  validates :serial_no, uniqueness: :product_id
end
