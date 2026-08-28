require 'test_helper'

class ConsumablesControllerTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  setup do
    login_as(members(:baloo_10eme))
  end

  test "GET #index returns the list of consumables for the current_group" do
    get "/consumables"

    assert_response :success
    assert_template "consumables/index"
    assert_select "aside.forest-filter-sidebar-column" do
      assert_select "#desktop-consumable-filters"
    end
    assert_select "details.forest-mobile-filters"
    assert_select "article.forest-consumable-card", count: 1
    assert_select "article.forest-consumable-card .forest-product-card__title", text: consumables(:cans_of_soup).name
  end

  test "GET #show uses Forest stock facts and transaction history" do
    get consumable_path(consumables(:cans_of_soup))

    assert_response :success
    assert_select ".forest-product-summary"
    assert_select ".forest-product-stock-total", text: /en stock/
    assert_select ".forest-product-facts"
    assert_select ".forest-consumable-transactions-table"
    assert_select ".forest-product-actions"
  end

  test "GET #new and #edit use the Forest consumable form" do
    get new_consumable_path

    assert_response :success
    assert_select "form.forest-product-form"
    assert_select ".forest-form-section", count: 5
    assert_select ".forest-form-check-label", minimum: 1

    get edit_consumable_path(consumables(:cans_of_soup))

    assert_response :success
    assert_select "form.forest-product-form"
  end
end
