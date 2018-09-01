class Instance < ApplicationRecord
  include HasSlug

  belongs_to :product, touch: true
  has_many :reservations, dependent: :delete_all, autosave: true

  validates :product, :serial_no, :slug, presence: true
  validates :serial_no, uniqueness: :product_id

  after_initialize :assign_serial_no

  def has_no_reservations?
    reservations.empty?
  end

  def reserved_on?(dates)
    reservations.any?{|reservation| reservation.overlaps?(dates)}
  end

  def assign_serial_no
    self.serial_no = generate_serial_no if self.serial_no.blank?
  end

  def generate_serial_no
    SecureRandom.alphanumeric(3).upcase
  end
end
