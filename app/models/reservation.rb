class Reservation < ApplicationRecord
  include HasSlug

  belongs_to :instance
  has_one :product, through: :instance
  belongs_to :event

  has_many :domain_events, dependent: :delete_all, autosave: true, as: :model

  scope :with_product, ->{ includes(:product) }

  validates :instance, :event, presence: true
  validates :instance, uniqueness: { scope: :event }

  delegate :title, :start_on, :end_on, :date_range, :real_date_range, to: :event
  delegate :name, :slug, :sort_key_for_pickup, prefix: :product, to: :product
  delegate :slug, prefix: :instance, to: :instance
  delegate :serial_no, to: :instance

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

  def event_overlaps?(other_event)
    overlaps?(other_event.date_range)
  end

  def overlaps?(other_date_range)
    date_range.overlaps?(other_date_range)
  end
end
