class Reservation < ApplicationRecord
  include HasSlug

  belongs_to :product
  belongs_to :event

  scope :with_product, ->{ includes(:product) }

  validates :product, :event, presence: true
  validates :product, uniqueness: { scope: :event }

  def dates_overlap?(other_event)
    my_event_dates = self.event.date_range
    other_event_dates = other_event.date_range
    my_event_dates.overlaps?(other_event_dates)
  end
end
