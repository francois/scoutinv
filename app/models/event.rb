class Event < ApplicationRecord
  include HasSlug

  DoubleBookingError = Class.new(RuntimeError)

  belongs_to :group
  belongs_to :troop, optional: true
  has_many :reservations,  dependent: :delete_all, autosave: true
  has_many :notes,         dependent: :delete_all, autosave: true, as: :parent
  has_many :domain_events, dependent: :delete_all, autosave: true, as: :model

  scope :after, ->(date) { where("end_on >= ?", date).order(:start_on) }
  scope :by_date, -> { order(:start_on, :id) }
  scope :with_reservations, ->{ includes(reservations: :products) }

  validates :title, presence: true, length: { minimum: 2 }
  validates :start_on, :end_on, presence: true
  validate :ends_after_it_starts
  validate :troop_or_name_filled_in

  delegate :name, :address, to: :group, prefix: :group
  delegate :name, to: :troop, prefix: :troop

  state_machine :state, initial: :draft do
    event :finalize do
      transition :draft => :final, if: :internal?
      transition :draft => :ready
    end

    event :ready do
      transition :final => :ready
    end

    event :audit do
      transition :ready => :returned
    end

    event :redraw do
      transition [:final, :ready] => :draft
    end

    after_transition to: :final do |event|
      MemberMailer.notify_event_finalized(event).deliver_now
    end

    after_transition to: :ready do |event|
      MemberMailer.notify_event_ready(event).deliver_now
    end

    after_transition to: :returned do |event|
      MemberMailer.notify_event_returned(event).deliver_now
    end
  end

  def can_finalize?(member)
    state_events.include?(:finalize) && ((internal? && troop.members.include?(member)) || member.inventory_director?)
  end

  def can_ready?(member)
    state_events.include?(:ready) && member.inventory_director?
  end

  def can_audit?(member)
    state_events.include?(:audit) && member.inventory_director?
  end

  def can_redraw?(member)
    state_events.include?(:redraw) && member.inventory_director?
  end

  def can_change_reservations?(member)
    if draft?
      (internal? && troop.members.include?(member)) || member.inventory_director?
    else
      member.inventory_director?
    end
  end

  def can_reservations_change?
    draft?
  end

  def internal?
    !!troop
  end

  def renter_name
    troop && troop.name || name
  end

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

  def reserve(products, metadata: {})
    products.each do |product|
      # Attempt to find a free instance, e.g. one that isn't reserved for this event's date range
      available_instances            = product.instances.select(&:available?)
      my_reserved_instances          = reservations.map(&:instance)
      instances_busy_on_other_events = product.instances.select{|instance| instance.reserved_on?(date_range)}

      candidates = available_instances
      candidates = candidates - my_reserved_instances
      candidates = candidates - instances_busy_on_other_events

      if candidates.empty?
        raise DoubleBookingError, "There are no free instances of #{product.name} available between #{start_on} and #{end_on}"
      end

      unit_price  = product.unit_price(internal: internal?)
      reservation = reservations.build(instance: candidates.sample, unit_price: unit_price)
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

  def offer(products, metadata: {})
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
    reservations.each do |reservation|
      reservation.lease(date)
    end

    domain_events << LeasedAllInstances.new(
      data: {
        event_slug: slug,
        leased_on: date,
        instance_slugs: reservations.map(&:instance_slug),
      },
      metadata: metadata
    )
  end

  def lease(instances, date: Date.today, metadata: {})
    reservations.each do |reservation|
      next unless instances.include?(reservation.instance)

      reservation.lease(date)
      domain_events << InstanceLeased.new(
        data: {
          event_slug: slug,
          instance_slug: reservation.instance_slug,
          leased_on: date,
        },
        metadata: metadata
      )
    end
  end

  def return(instances, date: Date.today, metadata: {})
    reservations.each do |reservation|
      next unless instances.include?(reservation.instance)

      reservation.return(date)
      domain_events << InstanceReturned.new(
        data: {
          event_slug: slug,
          instance_slug: reservation.instance_slug,
          returned_on: date,
        },
        metadata: metadata
      )
    end
  end
  
  NoInstanceAvailable = Class.new(StandardError)

  def switch(instances, date: Date.today, metadata: {})
    reservations.each do |reservation|
      next unless instances.include?(reservation.instance)

      candidates = reservation.product.instances.reject{|instance| instance.reserved_on?(date_range)}
      raise NoInstanceAvailable if candidates.empty?

      reservation.mark_for_destruction
      new_reservation = reservations.build(instance: candidates.sample)

      domain_events << InstanceSwitched.new(
        data: {
          event_slug: slug,
          new_instance_slug: new_reservation.instance_slug,
          original_instance_slug: reservation.instance_slug,
        },
        metadata: metadata,
      )
    end
  end

  def reservations_of(product)
    reservations.select{|reservation| reservation.product == product}
  end

  def real_date_range
    start_on .. end_on
  end

  def date_range
    (start_on - 1) .. (end_on + 1)
  end

  def ends_after_it_starts
    return unless start_on && end_on
    errors.add(:base, "Events must end on or after they start") unless end_on >= start_on
  end

  def troop_or_name_filled_in
    return if troop.present? && name.blank?   && phone.blank?   && email.blank? \
    ||        troop.blank?   && name.present? && phone.present? && email.present?

    errors.add(:base, "Troop OR name + email + phone required")
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
