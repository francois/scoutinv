require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  setup do
    login_as members(:akela_10eme)
  end

  test "GET index uses Forest cards and filters" do
    get products_path

    assert_response :success
    assert_select "aside.forest-filter-sidebar-column" do
      assert_select "#desktop-product-filters"
      assert_select "#desktop-filter[placeholder='ex. tente, brûleur']"
      assert_select "label[for='desktop-category-#{categories(:kitchen).slug}'] .forest-filter-option__count", text: "1"
    end
    assert_select "details.forest-mobile-filters"
    assert_select "article.forest-inventory-product-card", count: 2
    assert_select "article.forest-inventory-product-card .forest-product-card__title", text: products(:tent_4x5_10eme).name
    assert_select "article.forest-inventory-product-card .forest-product-card__availability", text: /1 disponible à prêter/
    assert_select "table.product-list", count: 0
  end

  test "GET index keeps the search and category selection" do
    get products_path, params: {filter: "Cooking", category: categories(:kitchen).slug}

    assert_response :success
    assert_select "#desktop-filter[value='Cooking']"
    assert_select "#desktop-category-#{categories(:kitchen).slug}[checked]"
    assert_select "#desktop-product-filters .forest-filter-clear"
    assert_select "article.forest-inventory-product-card", count: 1
    assert_select ".forest-product-card__title", text: products(:cooking_plate_10eme).name
  end

  test "GET show uses Forest facts and instance states" do
    get product_path(products(:cooking_plate_10eme))

    assert_response :success
    assert_select ".forest-product-summary"
    assert_select ".forest-product-stock-total", text: /1 disponible à prêter/
    assert_select ".forest-product-facts", text: /Cuisine/
    assert_select ".forest-data-table .forest-instance-state.is-held", text: "Retenu"
    assert_select ".forest-product-danger-zone"
  end

  test "GET nested show keeps the event reserve action" do
    event = events(:summer_camp_911_10eme)
    product = products(:tent_4x5_10eme)

    get event_product_path(event, product)

    assert_response :success
    assert_select ".forest-product-event-action" do
      assert_select "form[action='#{event_reservations_path(event)}']"
      assert_select "input[name='products[#{product.slug}]'][value='1']"
      assert_select "input[name='add']"
    end
  end

  test "GET new and edit use the Forest product form" do
    get new_product_path

    assert_response :success
    assert_select "form.forest-product-form"
    assert_select ".forest-form-section", count: 5
    assert_select ".forest-form-check-label", minimum: 1

    get edit_product_path(products(:tent_4x5_10eme))

    assert_response :success
    assert_select "form.forest-product-form"
    assert_select "#product_name", value: "Tent, 4x5'"
  end
end
