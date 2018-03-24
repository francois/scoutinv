require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test "belongs to group" do
    assert_equal groups(:"10eme"), products(:cooking_plate_10eme).group
    assert groups(:"10eme").products.include?(products(:cooking_plate_10eme))
    refute groups(:"10eme").products.include?(products(:prospector_tent_41eme))
  end

  test ".in_category scope" do
    assert groups(:"10eme").products.in_category(categories(:tent)).include?(products(:tent_4x5_10eme))
    refute groups(:"10eme").products.in_category(categories(:tent)).include?(products(:cooking_plate_10eme))
    refute groups(:"10eme").products.in_category(categories(:tent)).include?(products(:prospector_tent_41eme))
    assert groups(:"41eme").products.in_category(categories(:tent)).include?(products(:prospector_tent_41eme))
  end
end
