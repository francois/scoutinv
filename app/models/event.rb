class Event < ApplicationRecord
  include HasSlug

  belongs_to :group
  has_many :reservations, autosave: true
  has_many :notes, as: :parent, autosave: true

  has_many :domain_events, as: :model, autosave: true

  scope :after, ->(date) { where("start_on >= ?", date).order(:start_on) }
  scope :by_date, -> { order(:start_on, :id) }
  scope :with_reservations, ->{ includes(reservations: :products) }

  validates :title, presence: true, length: { minimum: 2 }
  validates :start_on, :end_on, presence: true
  validate :ends_after_it_starts

  def add_note(attributes, metadata: {})
    notes.build(attributes).tap do |new_note|
      domain_events << NoteAddedToEvent.new(
        data: {
          author_slug: new_note.author_slug,
          body: new_note.body,
          event_slug: slug,
        },
        metadata: metadata
      )
    end
  end

  def change_information(attributes, metadata: {})
    self.attributes = attributes
    domain_events << EventIdentificationChanged.new(data: {event_slug: slug, title: title, description: description}, metadata: metadata) if title_changed? || description_changed?
    domain_events << EventDatesChanged.new(data: {event_slug: slug, start_on: start_on, end_on: end_on}, metadata: metadata)              if start_on_changed? || end_on_changed?
    save
  end

  def add(products, metadata: {})
    missing = products - reservations.map(&:product)
    missing.each do |product|
      reservations.build(product: product)
      domain_events << ProductReserved.new(
        data: {
          event_slug: slug,
          product_slug: product.slug
        },
        metadata: metadata
      )
    end
  end

  def remove(products, metadata: {})
    reservations.each do |reservation|
      reservation.mark_for_destruction if products.include?(reservation.product)
      domain_events << ProductReleased.new(
        data: {
          event_slug: slug,
          product_slug: reservation.product_slug,
        },
        metadata: metadata
      )
    end
  end

  def lease_all(date=Date.today, metadata: {})
    unleased = reservations.reject(&:leased?)
    unleased.each do |reservation|
      reservation.lease(date)
    end

    domain_events << EventLeasedAllReservations.new(
      data: {
        event_slug: slug,
        leased_on: date,
        product_slugs: reservations.map(&:product_slug),
      },
      metadata: metadata
    )
  end

  def lease(products, date: Date.today, metadata: {})
    reservations.each do |reservation|
      reservation.lease(date) if products.include?(reservation.product)
      domain_events << ProductLeased.new(
        data: {
          event_slug: slug,
          lease_on: reservation.product_slug,
          lease_date: date,
        },
        metadata: metadata
      )
    end
  end

  def return(products, date: Date.today, metadata: {})
    reservations.each do |reservation|
      reservation.return(date) if products.include?(reservation.product)
      domain_events << ProductReturned.new(
        data: {
          event_slug: slug,
          return_on: date,
          product_slug: reservation.product_slug,
        },
        metadata: metadata
      )
    end
  end

  def real_date_range
    start_on .. end_on
  end

  def date_range
    (start_on - 1) .. (end_on + 1)
  end

  def ends_after_it_starts
    return unless start_on && end_on
    errors.add("Events must end on or after they start") unless end_on >= start_on
  end
end
