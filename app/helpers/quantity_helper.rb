module QuantityHelper
  include SI

  # non-breaking space, &#160;
  NBSP = " ".freeze


  def format_quantity(quantity, precision: 1, si_prefix: nil, short: true)
    quantity = case quantity
               when nil      ; Quantity.zero
               when Quantity ; quantity
               else Quantity.new(quantity, SI::BASE, "unit")
               end
    return 0 if quantity.zero?

    basic_quantity = quantity.to_base
    value, prefix =
      if si_prefix
        [quantity.to(si_prefix).value, si_prefix]
      else
        if basic_quantity.value >= 1000
          [quantity.to_kilo.value, KILO]
        elsif basic_quantity.value < 1
          [quantity.to_milli.value, MILLI]
        else
          [basic_quantity.value, BASE]
        end
      end

    suffix =
      if short
        I18n.translate(quantity.unit, scope: "unit.short", count: value)
      else
        I18n.translate(quantity.unit, scope: "unit.long", count: value)
      end

    number_with_precision(value, precision: precision) + NBSP + I18n.translate(prefix, scope: "si_prefix.#{short ? :short : :long}") + suffix
  end
end
