require 'test_helper'

class ConsumableTest < ActiveSupport::TestCase
  test "it roundtrips #base_quantity" do
    assert_equal 1, consumables(:cans_of_soup).base_quantity_value
    assert_equal SI::BASE, consumables(:cans_of_soup).base_quantity_si_prefix
    assert_equal "unit", consumables(:cans_of_soup).base_quantity_unit
    assert_equal Quantity.new(1, SI::BASE, "unit"), consumables(:cans_of_soup).base_quantity

    consumable = Consumable.create!(group: groups(:"10eme"), name: "consumable", base_quantity: Quantity.new(500, SI::MILLI, "litre"))
    assert_equal 500, consumable.base_quantity_value
    assert_equal SI::MILLI, consumable.base_quantity_si_prefix
    assert_equal "litre", consumable.base_quantity_unit

    consumable = Consumable.find(consumable.id)
    assert_equal Quantity.new(0.5, SI::BASE, "litre"), consumable.base_quantity
  end
end
