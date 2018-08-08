class Instance < ApplicationRecord
  include HasSlug

  belongs_to :product, touch: true
  has_many :reservations, dependent: :delete_all, autosave: true

  validates :product, :serial_no, :slug, presence: true
  validates :serial_no, uniqueness: :product_id

  def has_no_reservations?
    reservations.empty?
  end

  def reserved_on?(dates)
    reservations.any?{|reservation| reservation.overlaps?(dates)}
  end
end
