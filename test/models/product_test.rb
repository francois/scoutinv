require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test "belongs to group" do
    assert_equal groups(:"10eme"), products(:cooking_plate_10eme).group
    assert groups(:"10eme").products.include?(products(:cooking_plate_10eme))
    refute groups(:"10eme").products.include?(products(:prospector_tent_41eme))
  end
end
