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

class ProductInstanceTest < ActiveSupport::TestCase
  setup do
    @product = groups(:"10eme").products.create!(name: "product 5", quantity: 5)
    assert_equal 5, @product.reload.instances.size
  end

  test "destroys instances when quantity is reduced" do
    @product.attributes = { quantity: 4 }
    @product.save!
    assert_equal 4, @product.reload.instances.size

    @product.attributes = { quantity: 1 }
    @product.save!
    assert_equal 1, @product.reload.instances.size
  end

  test "refuses to set quantity at or below 0" do
    @product.attributes = { quantity: 0 }
    assert_equal false, @product.save
    assert_equal 5, @product.reload.instances.size
  end

  test "increases the number of instances when quantity is increased" do
    @product.attributes = { quantity: 7 }
    @product.save!
    assert_equal 7, @product.reload.instances.size
  end
end
