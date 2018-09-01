class Event < ApplicationRecord
  include HasSlug

  belongs_to :group
  has_many :reservations,  dependent: :delete_all, autosave: true
  has_many :notes,         dependent: :delete_all, autosave: true, as: :parent
  has_many :domain_events, dependent: :delete_all, autosave: true, as: :model

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
    products.each do |product|
      # Attempt to find a free instance, e.g. one that isn't reserved for this event's date range
      my_reserved_instances          = reservations.map(&:instance)
      instances_busy_on_other_events = product.instances.reject{|instance| instance.reserved_on?(date_range)}

      candidates = product.instances
      candidates = candidates - my_reserved_instances
      candidates = candidates - instances_busy_on_other_events

      # If we couldn't find a free instance, fallback to any instance
      # It is a conscious decision to let humans take the correct decision in this case
      # The UI will inform people that an instance is double booked
      #
      # If we decide to change this decision, we could raise a DoubleBookingError error
      # and let the human take a decision at that time
      Rails.logger.debug "For product #{product.name} (#{product.slug}), falling back to a busy instance because none are free" if candidates.empty?
      candidates = product.instances if candidates.empty?

      reservation = reservations.build(instance: candidates.sample)
      domain_events << InstanceReserved.new(
        data: {
          event_slug: slug,
          instance_slug: reservation.instance_slug,
          product_slug: product.slug,
        },
        metadata: metadata
      )
    end
  end

  def remove(products, metadata: {})
    double_booking_errors = Product.double_booked(self).to_a

    # When removing a product, we attempt to remove any double
    # booked instances first
    reservations.each do |reservation|
      next unless products.include?(reservation.product)
      if index = double_booking_errors.find_index(reservation.product)
        next unless double_booking_errors[index].double_booked_instance_ids.include?(reservation.instance_id)
        products = remove_reservation(reservation, products, metadata)
        break if products.empty? # performance optimization
      end

      return if products.empty?

      # If we still have to remove products, then we fallback to
      # removing any instance
      reservations.each do |reservation|
        next unless products.include?(reservation.product)
        products = remove_reservation(reservation, products, metadata)
        break if products.empty? # performance optimization
      end
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

  private

  def remove_reservation(reservation, products, metadata)
    reservation.mark_for_destruction
    domain_events << InstanceReleased.new(
      data: {
        event_slug: slug,
        instance_slug: reservation.instance_slug,
        product_slug: reservation.product_slug,
      },
      metadata: metadata
    )

    products = products - [ reservation.product ]
  end
end
