class ConsumableTransaction < ApplicationRecord
  belongs_to :consumable
  belongs_to :event, optional: true

  validates :quantity_value, presence: true, numericality: { only_integer: false }
  validates :quantity_si_prefix, presence: true, inclusion: SI::ALL
  validates :quantity_unit, presence: true, inclusion: %w( unit pound litre gram ).freeze
  validate :reason_or_event
  validate :unit_same_as_parent

  composed_of :quantity, class_name: "Quantity", mapping: [%w(quantity_value value), %w(quantity_si_prefix si_prefix), %w(quantity_unit unit)],
    allow_nil: false,
    converter: ->(value){ QuantityParser.new.parse(value) }

  def date
    (event&.start_on || created_at || Date.current).to_date
  end

  private

  def reason_or_event
    return if reason.present? || event.present?
    errors.add(:event, "must be present, or reason must be specified")
  end

  def unit_same_as_parent
    return if quantity.unit == consumable.unit
    errors.add(:quantity, "must have same unit as consumable; expected #{consumable.unit}, found #{quantity.unit}")
  end
end
