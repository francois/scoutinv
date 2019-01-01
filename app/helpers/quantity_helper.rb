module QuantityHelper
  include SI

  # non-breaking space, &#160;
  NBSP = " ".freeze


  def format_quantity(quantity, precision: 0, short: true)
    return 0 if quantity.zero?

    basic_quantity = quantity.to_base
    value, prefix =
      if basic_quantity.value > 1000
        [quantity.to_kilo.value, KILO]
      elsif basic_quantity.value < 1
        [quantity.to_milli.value, MILLI]
      else
        [basic_quantity.value, BASE]
      end

    suffix =
      if short
        I18n.translate(quantity.unit, scope: "unit.short")
      else
        I18n.translate(quantity.unit, scope: "unit.long").pluralize(value)
      end

    if value == 1
      I18n.translate(prefix, scope: "si_prefix.#{short ? :short : :long}") + suffix
    else
      number_with_precision(value, precision: precision) + NBSP + I18n.translate(prefix, scope: "si_prefix.#{short ? :short : :long}") + suffix
    end
  end
end
