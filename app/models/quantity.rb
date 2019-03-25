Quantity = Struct.new(:value, :si_prefix, :unit) do
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations
  include ActiveModel::Conversion

  validates :value, presence: true
  validates :value, numericality: { only_integer: false, allow_blank: false }
  validates :si_prefix, inclusion: {in: [SI::MILLI, SI::BASE, SI::KILO], allow_nil: false}
  validates :unit, inclusion: %w(unit gram litre pound)

  delegate :zero?, :nonzero?, to: :value

  CONVERSIONS = {
    "unit:unit"   => 1,
    "litre:litre" => 1,
    "gram:gram"   => 1,
    "pound:pound" => 1,

    "gram:pound"  => 453.5924,
    "pound:gram"  => 0.002204623,
  }.freeze

  def ==(other)
    me   = to_base
    them = other.to_base

    # SI prefix is guaranteed to be the same through the calls to #to_base above
    me.value == them.value && me.unit == them.unit
  end

  def to_s
    "#{BigDecimal(value).to_s("F")} #{si_prefix}#{unit}"
  end

  def zero?
    value.zero?
  end

  def nonzero?
    !zero?
  end

  def +(other)
    a = to_base
    b = other.to_base
    Quantity.new(
      CONVERSIONS.fetch([a.unit, b.unit].join(":")) * (a.value + b.value),
      SI::BASE,
      b.unit
    )
  end

  def -(other)
    a = to_base
    b = other.to_base
    Quantity.new(
      CONVERSIONS.fetch([a.unit, b.unit].join(":")) * (a.value - b.value),
      SI::BASE,
      b.unit
    )
  end

  def scale(multiplicand)
    Quantity.new(value * multiplicand, si_prefix, unit)
  end

  def to_kilo
    case si_prefix
    when SI::KILO  ; self
    when SI::BASE  ; Quantity.new(value / BigDecimal(1000), SI::KILO, unit)
    when SI::MILLI ; Quantity.new(value / BigDecimal(1000) / BigDecimal(1000), SI::KILO, unit)
    else
      raise "Unknown SI prefix: #{si_prefix.inspect}"
    end
  end

  def to_base
    case si_prefix
    when SI::KILO  ; Quantity.new(value * BigDecimal(1000), SI::BASE, unit)
    when SI::BASE  ; self
    when SI::MILLI ; Quantity.new(value / BigDecimal(1000), SI::BASE, unit)
    else
      raise "Unknown SI prefix: #{si_prefix.inspect}"
    end
  end

  def to_milli
    case si_prefix
    when SI::KILO  ; Quantity.new(value * BigDecimal(1000) * BigDecimal(1000), SI::MILLI, unit)
    when SI::BASE  ; Quantity.new(value * BigDecimal(1000), SI::MILLI, unit)
    when SI::MILLI ; self
    else
      raise "Unknown SI prefix: #{si_prefix.inspect}"
    end
  end

  def to(new_prefix)
    case new_prefix
    when SI::KILO  ; to_kilo
    when SI::BASE  ; to_base
    when SI::MILLI ; to_milli
    else
      raise "Unknown SI prefix to convert to: #{new_prefix.inspect}"
    end
  end

  def self.can_convert_between?(unit_a, unit_b)
    CONVERSIONS.include?([unit_a, unit_b].join(":"))
  end

  def self.zero(unit = "unit")
    Quantity.new(0, SI::BASE, unit)
  end
end
