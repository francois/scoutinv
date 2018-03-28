class Reservation < ApplicationRecord
  include HasSlug

  belongs_to :product
  belongs_to :event

  scope :with_product, ->{ includes(:product) }

  validates :product, :event, presence: true
  validates :product, uniqueness: { scope: :event }

  delegate :title, :start_on, :end_on,:date_range, to: :event

  def dates_overlap?(other_event)
    date_range.overlaps?(other_event.date_range)
  end
end
