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
    SecureRandom.alphanumeric(self.class.serial_no_size).upcase
  end

  # Because of the birthday paradox, the more instances we have, the
  # longer the size of the serial number must use to have less than
  # 50% chance of hitting a duplicate key error for the serial no.
  #
  # This number is dynamically calculated based on the total number
  # of instances.
  #
  # @see https://en.wikipedia.org/wiki/Birthday_paradox
  def self.serial_no_size
    @serial_no_size ||=
      begin
        number = Instance.count
        number.zero? ? 3 : Math.log(number, 10).truncate + 1
      end
  end
end
