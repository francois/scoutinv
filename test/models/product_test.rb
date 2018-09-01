require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  setup do
    @group = groups(:"10eme")
  end

  test "belongs to group" do
    assert_equal @group, products(:cooking_plate_10eme).group
    assert @group.products.include?(products(:cooking_plate_10eme))
    refute @group.products.include?(products(:prospector_tent_41eme))
  end

  test ".in_category scope" do
    assert @group.products.in_category(categories(:tent)).include?(products(:tent_4x5_10eme))
    refute @group.products.in_category(categories(:tent)).include?(products(:cooking_plate_10eme))
    refute @group.products.in_category(categories(:tent)).include?(products(:prospector_tent_41eme))
    assert groups(:"41eme").products.in_category(categories(:tent)).include?(products(:prospector_tent_41eme))
  end

  test ".search with ASCII string finds corresponding product" do
    assert @group.products.search("tent").include?(products(:tent_4x5_10eme))
    refute @group.products.search("tent").include?(products(:cooking_plate_10eme))
    refute @group.products.search("tent").include?(products(:prospector_tent_41eme))
  end

  test ".search with accented string finds unaccented product" do
    product = @group.register_new_product(name: "Bruleur", categories: [ categories(:kitchen) ])
    @group.save!

    assert @group.products.search("brûleur").include?(product)
  end

  test ".search with unaccented string finds accented product" do
    product = @group.register_new_product(name: "Brûleur", categories: [ categories(:kitchen) ])
    @group.save!

    assert @group.products.search("bruleur").include?(product)
  end

  test ".search with ASCII string and category finds correct products" do
    assert @group.products.in_category(categories(:tent)).search("tent").include?(products(:tent_4x5_10eme))
    refute @group.products.in_category(categories(:tent)).search("plate").include?(products(:cooking_plate_10eme))
    refute @group.products.in_category(categories(:kitchen)).search("tent").include?(products(:tent_4x5_10eme))
    refute @group.products.in_category(categories(:tent)).search("prospector").include?(products(:prospector_tent_41eme))
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
