require 'test_helper'

class QuantityParserTest < ActiveSupport::TestCase
  test "parses '41 mlbs' into '41 millipounds'" do
    assert_equal Quantity.new(41, SI::MILLI, "pound"), QuantityParser.new.parse("41 mlbs")
  end

  test "parses '8430 ml' into '8.43 litres'" do
    assert_equal Quantity.new(8.43, SI::BASE, "litre"), QuantityParser.new.parse("8430 ml")
  end

  test "parses '8.43l' into '8430 millilitres'" do
    assert_equal Quantity.new(8430, SI::MILLI, "litre"), QuantityParser.new.parse("8.43l")
  end

  test "parses '8,43l' into '8430 millilitres'" do
    assert_equal Quantity.new(8430, SI::MILLI, "litre"), QuantityParser.new.parse("8,43l")
  end

  test "parsed '' into 0" do
    assert_equal Quantity.zero, QuantityParser.new.parse("")
  end

  test "parsed nil into 0" do
    assert_equal Quantity.zero, QuantityParser.new.parse(nil)
  end

  test "parses 'unité' into '1 unit'" do
    assert_equal Quantity.new(1, SI::BASE, "unit"), QuantityParser.new.parse("unité")
    assert_equal Quantity.new(1, SI::BASE, "unit"), QuantityParser.new.parse("unités")
  end

  test "parses '5 lbs' into '5 pounds'" do
    assert_equal Quantity.new(5, SI::BASE, "pound"), QuantityParser.new.parse("5 lb")
    assert_equal Quantity.new(5, SI::BASE, "pound"), QuantityParser.new.parse("5 lbs")
    assert_equal Quantity.new(5, SI::BASE, "pound"), QuantityParser.new.parse("5 lb") # with NBSP
    assert_equal Quantity.new(5, SI::BASE, "pound"), QuantityParser.new.parse("5 lbs") # with NBSP
  end

  test "parses '-500g' into '-500 grams'" do
    assert_equal Quantity.new(-500, SI::BASE, "gram"), QuantityParser.new.parse("-500g")
  end
end
