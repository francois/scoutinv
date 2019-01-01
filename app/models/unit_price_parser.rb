class UnitPriceParser
  include ActionView::Helpers::NumberHelper

  # Optional space
  O_SPACE   = /\s*/
  PRICE     = /(?:\d+(?:[,.]\d+)?)/
  SI_PREFIX = /(?:k|kilo|m|milli)/
  UNIT      = /(?:g|grams?|grammes?|l|litres?|u|units?|pounds?|lbs?|livres?|u|units?|unités?)/
  VALUE     = /\d+/
  CURRENCY  = /[$]/
  SLASH     = /\//

  UNIT_TO_UNIT = {
    "g"       => "gram",
    "gram"    => "gram",
    "gramme"  => "gram",
    "grammes" => "gram",
    "grams"   => "gram",

    "l"       => "litre",
    "litre"   => "litre",
    "litres"  => "litre",

    "lb"      => "pound",
    "lbs"     => "pound",
    "livre"   => "pound",
    "livres"  => "pound",
    "pound"   => "pound",
    "pounds"  => "pound",

    "u"       => "unit",
    "unit"    => "unit",
    "units"   => "unit",
    "unité"   => "unit",
    "unités"  => "unit",
  }.freeze

  def parse(str)
    results = str.match(/\A#{O_SPACE}#{CURRENCY}?#{O_SPACE}(#{PRICE})#{O_SPACE}#{CURRENCY}?#{O_SPACE}(?:#{SLASH}#{O_SPACE}(#{VALUE})?#{O_SPACE}(#{SI_PREFIX})?(#{UNIT})?)?#{O_SPACE}\z/)
    return nil unless results

    si_prefix =
      case results[3] || SI::BASE
      when "m", SI::MILLI ; SI::MILLI
      when SI::BASE       ; SI::BASE
      when "k", SI::KILO  ; SI::KILO
      else
        return nil
      end

    unit = UNIT_TO_UNIT[ results[4] || "unit" ]
    return nil unless unit

    {
      unit_price: BigDecimal((results[1] || "1").gsub(",", ".")),
      unit_price_value: BigDecimal(results[2] || 1),
      unit_price_si_prefix: si_prefix,
      unit_price_unit: unit,
    }
  end

  def format(unit_price_value:, unit_price_si_prefix:, unit_price_unit:, unit_price:, verbose: false)
    unit      = I18n.translate(unit_price_unit, scope: "unit.#{verbose ? :long : :short}")
    si_prefix = I18n.translate(unit_price_si_prefix, scope: "si_prefix.#{verbose ? :long : :short}")
    unit      = unit.pluralize(unit_price_value) if verbose && unit

    if unit_price_value == 1
      "%s / %s%s" % [number_to_currency(unit_price, precision: 2), si_prefix, unit]
    else
      "%s / %s %s%s" % [number_to_currency(unit_price, precision: 2), number_with_precision(unit_price_value, precision: 0), si_prefix, unit]
    end.strip.sub(/ \/$/, "")
  end
end
