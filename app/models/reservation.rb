class Reservation < ApplicationRecord
  include HasSlug
  belongs_to :group

  validates :title, presence: true, length: { minimum: 2 }
  validates :start_on, :end_on, presence: true
  validate :ends_after_it_starts

  def ends_after_it_starts
    return unless start_on && end_on
    errors.add("Reservations must end on or after they start") unless end_on >= start_on
  end
end
