require 'test_helper'

class QuantityTest < ActiveSupport::TestCase
  include SI

  test "is valid with values and known SI prefixes" do
    assert Quantity.new(15, KILO, "gram").valid?
    assert Quantity.new(-15, BASE, "gram").valid?
    assert Quantity.new(42, MILLI, "gram").valid?
    assert Quantity.new("42", MILLI, "gram").valid?
    assert Quantity.new(42.1, MILLI, "gram").valid?
  end

  test "is invalid when SI prefix is nil or one we don't support" do
    refute Quantity.new(1, "mega", "gram").valid?
    refute Quantity.new(1, nil, "gram").valid?
    refute Quantity.new(1, "pico", "gram").valid?
    refute Quantity.new(1, "bingo", "gram").valid?
  end

  test "is invalid without a value" do
    refute Quantity.new(nil, BASE, "gram").valid?
  end

  test "can convert to base" do
    assert_equal Quantity.new(15000, BASE, "gram"), Quantity.new(15, KILO, "gram").to_base
    assert_equal Quantity.new(56, BASE, "gram"), Quantity.new(56, BASE, "gram").to_base
    assert_equal Quantity.new(BigDecimal("0.015"), BASE, "gram"), Quantity.new(15, MILLI, "gram").to_base
  end

  test "can convert to kilo" do
    assert_equal Quantity.new(-33, KILO, "gram"), Quantity.new(-33, KILO, "gram").to_kilo
    assert_equal Quantity.new(15, KILO, "gram"), Quantity.new(15000, BASE, "gram").to_kilo
    assert_equal Quantity.new(BigDecimal("0.000021"), KILO, "gram"), Quantity.new(21, MILLI, "gram").to_kilo
  end

  test "can convert to milli" do
    assert_equal Quantity.new(1000*1000, MILLI, "gram"), Quantity.new(1, KILO, "gram").to_milli
    assert_equal Quantity.new(1000, MILLI, "gram"), Quantity.new(1, BASE, "gram").to_milli
    assert_equal Quantity.new(BigDecimal("0.001"), MILLI, "gram"), Quantity.new(BigDecimal("0.001"), MILLI, "gram").to_milli
  end

  test "can convert dynamically" do
    assert_equal Quantity.new(1_000_000, MILLI, "gram"), Quantity.new(1, KILO, "gram").to(MILLI)
    assert_equal Quantity.new(1_000, BASE, "gram"), Quantity.new(1, KILO, "gram").to(BASE)
    assert_equal Quantity.new(1, KILO, "gram"), Quantity.new(1, KILO, "gram").to(KILO)
  end

  test "can add two quantities with the same prefix" do
    assert_equal Quantity.new(15_000 + 32_000, BASE, "gram"), Quantity.new(15, KILO, "gram") + Quantity.new(32, KILO, "gram")
  end

  test "can add two quantities different prefixes" do
    assert_equal Quantity.new(15_000 + 32 + BigDecimal("0.001"), BASE, "gram"), Quantity.new(15, KILO, "gram") + Quantity.new(32, BASE, "gram") + Quantity.new(1, MILLI, "gram")
  end

  test "can substract two quantities with the same prefix" do
    assert_equal Quantity.new(15_000 - 87_000, BASE, "gram"), Quantity.new(15, KILO, "gram") - Quantity.new(87, KILO, "gram")
  end

  test "can substract two quantities with different prefixes" do
    assert_equal Quantity.new(15 - BigDecimal("0.087") - 1000, BASE, "gram"), Quantity.new(15, BASE, "gram") - Quantity.new(87, MILLI, "gram") - Quantity.new(1, KILO, "gram")
  end

  test "can scale by multiplication" do
    assert_equal Quantity.new(15 * 42, KILO, "gram"), Quantity.new(15, KILO, "gram").scale(42)
    assert_equal Quantity.new(72 * -5, BASE, "gram"), Quantity.new(72, BASE, "gram").scale(-5)
    assert_equal Quantity.new(15 * 31, MILLI, "gram"), Quantity.new(15, MILLI, "gram").scale(31)
  end

  test ".zero" do
    assert_equal Quantity.new(0, BASE, "unit"), Quantity.zero
  end
end
