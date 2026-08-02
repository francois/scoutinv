require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup do
    @member = members(:akela_10eme)
  end

  test "inventory director adds a product image and rotates it" do
    login_as(@member)
    visit new_product_path

    fill_in "product_name", with: "Portrait image product"
    fill_in "product_quantity", with: 1
    attach_file "product_images", image_file(width: 20, height: 30, color: "red")
    click_button I18n.t("helpers.submit.create", model: Product.model_name.human)

    assert_selector ".entity-image", count: 1
    image_card_id = find(".entity-image")[:id]

    within "##{image_card_id}" do
      find("form[action$='/right'] button").click
    end

    assert_no_selector "##{image_card_id}"
    assert_selector ".entity-image", count: 1
    refute_equal image_card_id, find(".entity-image")[:id]
  end

  test "inventory director adds several product images at once" do
    login_as(@member)
    visit new_product_path

    fill_in "product_name", with: "Multiple images product"
    fill_in "product_quantity", with: 1
    attach_file "product_images", [
      image_file(width: 20, height: 30, color: "red"),
      image_file(width: 30, height: 20, color: "blue"),
    ]
    click_button I18n.t("helpers.submit.create", model: Product.model_name.human)

    assert_selector ".entity-image", count: 2
  end
end
