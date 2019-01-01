class QuantityParser
  include ActionView::Helpers::NumberHelper

  # Optional space
  O_SPACE   = /[\s\u00a0]*/ # include NBSP in the list of space characters
  SI_PREFIX = /(?:k|kilo|m|milli)/
  UNIT      = /(?:g|grams?|grammes?|l|litres?|u|units?|unités?|pounds?|lbs?|livres?)/
  VALUE     = /\d+(?:[.,]\d+)?/
  SLASH     = /\//

  UNIT_TO_UNIT = {
    "g"       => "gram",
    "gram"    => "gram",
    "grams"   => "gram",
    "gramme"  => "gram",
    "grammes" => "gram",
    "l"       => "litre",
    "litre"   => "litre",
    "litres"  => "litre",
    "u"       => "unit",
    "unit"    => "unit",
    "unité"   => "unit",
    "units"   => "unit",
    "unités"  => "unit",
    "pound"   => "pound",
    "pounds"  => "pound",
    "lb"      => "pound",
    "lbs"     => "pound",
    "livre"   => "pound",
    "livres"  => "pound",
  }.freeze

  def parse(str)
    return Quantity.zero if str.blank?

    results = str.match(/\A#{O_SPACE}(#{VALUE})?#{O_SPACE}(#{SI_PREFIX})?(#{UNIT})?#{O_SPACE}\z/)
    return nil unless results

    si_prefix =
      case results[2] || SI::BASE
      when "m", SI::MILLI ; SI::MILLI
      when SI::BASE       ; SI::BASE
      when "k", SI::KILO  ; SI::KILO
      else
        return nil
      end

    unit = UNIT_TO_UNIT[ results[3] || "unit" ]
    return nil unless unit

    Quantity.new(
      BigDecimal((results[1] || "1").gsub(",", ".")),
      si_prefix,
      unit,
    )
  end
end
