require 'test_helper'

class UnitPriceParserTest < ActiveSupport::TestCase
  setup do
    @original_locale = I18n.locale
    I18n.locale = :en

    @parser = UnitPriceParser.new
  end

  teardown do
    I18n.locale = @original_locale
  end

  test "parses '1,75 $ / 500 grammes' into '1.75 / 500 grams" do
    result = @parser.parse("1,75 $ / 500 grammes")
    refute result.nil?

    assert_equal 500, result[:unit_price_value]
    assert_equal BigDecimal("1.75"), result[:unit_price]
    assert_equal SI::BASE, result[:unit_price_si_prefix]
    assert_equal "gram", result[:unit_price_unit]
  end

  test "parses '2.49' into '2.49 $ per unit'" do
    result = @parser.parse("2.49")
    refute result.nil?

    assert_equal 1, result[:unit_price_value]
    assert_equal BigDecimal("2.49"), result[:unit_price]
    assert_equal SI::BASE, result[:unit_price_si_prefix]
    assert_equal "unit", result[:unit_price_unit]
  end

  test "parses '1.23/g' into '1,23 $ per gram'" do
    result = @parser.parse("1.23/g")
    refute result.nil?

    assert_equal 1, result[:unit_price_value]
    assert_equal BigDecimal("1.23"), result[:unit_price]
    assert_equal SI::BASE, result[:unit_price_si_prefix]
    assert_equal "gram", result[:unit_price_unit]
  end

  test "parses '1,41/250 millilitre' into '1,41 $ per 250 millilitre'" do
    result = @parser.parse("1,41/250 millilitre")
    refute result.nil?

    assert_equal 250, result[:unit_price_value]
    assert_equal BigDecimal("1.41"), result[:unit_price]
    assert_equal SI::MILLI, result[:unit_price_si_prefix]
    assert_equal "litre", result[:unit_price_unit]
  end

  test "parses '2.41$/kg' into '2,41 $ per kilogram'" do
    result = @parser.parse("2.41$/kg")
    refute result.nil?

    assert_equal 1, result[:unit_price_value]
    assert_equal BigDecimal("2.41"), result[:unit_price]
    assert_equal SI::KILO, result[:unit_price_si_prefix]
    assert_equal "gram", result[:unit_price_unit]
  end

  test "parses ' $ 14.33 / 2mlb' into '14.33 $ / millipound'" do
    result = @parser.parse(" $ 14.33 / 2mlb")
    refute result.nil?

    assert_equal 2, result[:unit_price_value]
    assert_equal BigDecimal("14.33"), result[:unit_price]
    assert_equal SI::MILLI, result[:unit_price_si_prefix]
    assert_equal "pound", result[:unit_price_unit]
  end

  test "formats '15 $ / 500 millilitre' into '15.00 $ / 500 ml'" do
    result = @parser.format(unit_price_value: 500, unit_price_si_prefix: SI::MILLI, unit_price_unit: "litre", unit_price: BigDecimal("15"))
    assert_equal "$15.00 / 500 ml", result
  end

  test "roundtrips '$4.49 / 250mlb'" do
    result = @parser.parse(@parser.format(unit_price_value: 250, unit_price_si_prefix: SI::MILLI, unit_price_unit: "pound", unit_price: BigDecimal("4.49")))
    refute result.nil?

    assert_equal 250, result[:unit_price_value]
    assert_equal SI::MILLI, result[:unit_price_si_prefix]
    assert_equal "pound", result[:unit_price_unit]
    assert_equal BigDecimal("4.49"), result[:unit_price]
  end

  test "records '0/1u' as '0 $ / unit'" do
    result = @parser.parse("0/1u")
    refute result.nil?

    assert_equal 1, result[:unit_price_value]
    assert_equal SI::BASE, result[:unit_price_si_prefix]
    assert_equal "unit", result[:unit_price_unit]
    assert_equal BigDecimal("0"), result[:unit_price]
  end
end
