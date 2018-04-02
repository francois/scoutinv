class Reservation < ApplicationRecord
  include HasSlug

  belongs_to :product
  belongs_to :event

  has_many :domain_events, as: :model, autosave: true

  scope :with_product, ->{ includes(:product) }

  validates :product, :event, presence: true
  validates :product, uniqueness: { scope: :event }

  delegate :title, :start_on, :end_on, :date_range, to: :event
  delegate :name, :slug, :sort_key_for_pickup, prefix: :product, to: :product

  def leased?
    returned_on.blank? && leased_on
  end

  def lease(date)
    raise ArgumentError, "Can't lease if product already out" unless leased_on.blank?

    self.leased_on = date
  end

  def return(date)
    raise ArgumentError, "Can't return if not leased" unless leased_on
    raise ArgumentError, "Can't return if product already returned" unless returned_on.blank?

    self.returned_on = date
  end

  def dates_overlap?(other_event)
    date_range.overlaps?(other_event.date_range)
  end
end
