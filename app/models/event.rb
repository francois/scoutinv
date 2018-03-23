class Event < ApplicationRecord
  include HasSlug

  belongs_to :group
  has_many :reservations, autosave: true

  scope :with_reservations, ->{ includes(reservations: :products) }

  validates :title, presence: true, length: { minimum: 2 }
  validates :start_on, :end_on, presence: true
  validate :ends_after_it_starts

  def date_range
    (start_on - 1) .. (end_on + 1)
  end

  def add(products)
    missing = products - reservations.map(&:product)
    missing.each do |product|
      reservations.build(product: product)
    end
  end

  def remove(products)
    reservations.each do |reservation|
      reservation.mark_for_destruction if products.include?(reservation.product)
    end
  end

  def ends_after_it_starts
    return unless start_on && end_on
    errors.add("Events must end on or after they start") unless end_on >= start_on
  end
end
