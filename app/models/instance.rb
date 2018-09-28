class Instance < ApplicationRecord
  include HasSlug

  belongs_to :product, touch: true
  has_many :reservations,  dependent: :delete_all, autosave: true
  has_many :domain_events, dependent: :delete_all, autosave: true, as: :model

  validates :product, :serial_no, :slug, presence: true
  validates :serial_no, uniqueness: true

  after_initialize :assign_serial_no

  # product_name
  # product_slug
  delegate :name, :slug, to: :product, prefix: :product

  state_machine :state, initial: :available do
    event :hold do
      transition %i[available] => :held
    end

    event :send_for_repairs do
      transition all - %i[repairing] => :repairing
    end

    event :repair do
      transition %i[held repairing] => :available
    end

    event :trash do
      transition all - %i[trashed] => :trashed
    end

    after_transition to: :held do |instance|
      instance.domain_events << InstanceHeld.new(
        data: {
          instance_slug: instance.slug,
          product_slug: instance.product_slug,
        },
        metadata: instance.instance_variable_get(:@action_metadata),
      )
    end

    after_transition to: :trashed do |instance|
      instance.domain_events << InstanceTrashed.new(
        data: {
          instance_slug: instance.slug,
          product_slug: instance.product_slug,
        },
        metadata: instance.instance_variable_get(:@action_metadata),
      )
    end

    after_transition to: :repairing do |instance|
      instance.domain_events << InstanceSentForRepairs.new(
        data: {
          instance_slug: instance.slug,
          product_slug: instance.product_slug,
        },
        metadata: instance.instance_variable_get(:@action_metadata),
      )
    end

    after_transition to: :available do |instance|
      instance.domain_events << InstanceReceivedFromRepairs.new(
        data: {
          instance_slug: instance.slug,
          product_slug: instance.product_slug,
        },
        metadata: instance.instance_variable_get(:@action_metadata),
      )
    end
  end

  def hold(metadata: {})
    @action_metadata = metadata
    super()
  end

  def send_for_repairs(metadata: {})
    @action_metadata = metadata
    super()
  end

  def repair(metadata: {})
    @action_metadata = metadata
    super()
  end

  def trash(metadata: {})
    @action_metadata = metadata
    super()
  end

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
        number.zero? ? 4 : [4, Math.log(number, 10).truncate + 1].max
      end
  end
end
