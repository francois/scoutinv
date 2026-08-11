require 'test_helper'

class Events::ReservationsControllerTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  setup do
    login_as members(:baloo_10eme)
    @url = "/events/#{ events(:summer_camp_911_10eme).slug }/reservations"

    assert products(:tent_4x5_10eme).reservations.empty?
    assert products(:cooking_plate_10eme).reservations.empty?
  end

  test "POST create with add=1 reserves an instance of the product" do
    post @url, params: {add: "1", products: { products(:tent_4x5_10eme).slug => "1" }}
    follow_redirect!
    assert_response :success
    assert products(:tent_4x5_10eme).reload.reservations.size == 1

    assert_select "#entity-card-#{products(:tent_4x5_10eme).slug}[data-selected-quantity='1']" do
      assert_select "article.forest-product-card.is-selected"
      assert_select "button.is-remove:not([disabled])", count: 1
      assert_select "button.is-add[disabled]", count: 1
    end
  end

  test "POST create with add=1 and two products reserves each instance" do
    post @url, params: {add: "1", products: { products(:cooking_plate_10eme).slug => "1", products(:tent_4x5_10eme).slug => "1" }}
    follow_redirect!
    assert_response :success
    assert products(:tent_4x5_10eme).reload.reservations.size == 1
    assert products(:cooking_plate_10eme).reload.reservations.size == 1
  end

  test "POST create with add=1 and format=js and two products reserves each instance" do
    post @url, params: {add: "1", products: { products(:cooking_plate_10eme).slug => "1", products(:tent_4x5_10eme).slug => "1" }, format: :js}
    assert_response :success
    assert products(:tent_4x5_10eme).reload.reservations.size == 1
    assert products(:cooking_plate_10eme).reload.reservations.size == 1
  end

  test "GET index shows event-aware stock in Forest product cards" do
    get @url

    assert_response :success
    assert_select "#entity-card-#{products(:tent_4x5_10eme).slug}[data-remaining-quantity='1'][data-selected-quantity='0'][data-total-quantity='1']" do
      assert_select "article.forest-product-card"
      assert_select ".forest-product-card__title", text: products(:tent_4x5_10eme).name
      assert_select ".forest-product-card__categories", text: I18n.t("categories.tent")
      assert_select ".forest-product-card__image-placeholder"
      assert_select "button.is-remove[disabled]", count: 1
      assert_select "button.is-add:not([disabled])", count: 1
    end

    assert_select "#entity-card-#{products(:cooking_plate_10eme).slug}[data-remaining-quantity='1'][data-total-quantity='2']" do
      assert_select ".forest-product-card__stock-facts", text: /1 non disponible/
    end
  end

  test "GET index shows the Forest search and category sidebar" do
    get @url

    assert_response :success
    assert_select "aside.forest-reservation-sidebar-column" do
      assert_select "#desktop-filter[placeholder='ex. bâche, brûleur']", count: 1
      assert_select "#desktop-only-show-my-reserved-products", count: 1
      assert_select "label[for='desktop-category-kitchen'] .forest-filter-option__count", text: "2"
      assert_select "label[for='desktop-category-tent'] .forest-filter-option__count", text: "1"
    end
    assert_select "details.forest-reservation-mobile-filters", count: 1
  end

  test "GET index keeps the full-text search in the sidebar" do
    get @url, params: {filter: "Cooking"}

    assert_response :success
    assert_select "#desktop-filter[value='Cooking']", count: 1
    assert_select "#desktop-reservation-filters a.forest-filter-clear", count: 1
    assert_select "#entity-card-#{products(:cooking_plate_10eme).slug}", count: 1
    assert_select "#entity-card-#{products(:tent_4x5_10eme).slug}", count: 0
  end

  test "GET index disables add and names overlapping bookings when no item is free" do
    event = create_overlapping_event("Other camp")
    event.reserve([ products(:tent_4x5_10eme) ])
    event.save!

    get @url

    assert_response :success
    assert_select "#entity-card-#{products(:tent_4x5_10eme).slug}[data-remaining-quantity='0']" do
      assert_select "article.forest-product-card.is-unavailable"
      assert_select "button.is-add[disabled]", count: 1
      assert_select ".forest-product-card__other-bookings", text: /Other camp/
    end
  end

  test "GET index identifies an exact instance booked by two events" do
    event = create_overlapping_event("Other camp")
    instance = instances(:tent_4x5_10eme)
    events(:summer_camp_911_10eme).reservations.create!(instance: instance, unit_price: 0)
    event.reservations.create!(instance: instance, unit_price: 0)

    get @url

    assert_response :success
    assert_select "#entity-card-#{products(:tent_4x5_10eme).slug}" do
      assert_select "article.forest-product-card.has-conflict"
      assert_select ".forest-product-card__conflict", text: /Other camp/
      assert_select ".forest-product-card__serial", text: /#{instance.serial_no}/
    end
  end

  private

  def create_overlapping_event(title)
    source = events(:summer_camp_911_10eme)
    Event.create!(
      group: source.group,
      troop: source.troop,
      title: title,
      pick_up_on: source.pick_up_on,
      start_on: source.start_on,
      end_on: source.end_on,
      return_on: source.return_on,
    )
  end
end

class Events::ReservationsControllerWithReservedTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  setup do
    login_as members(:baloo_10eme)
    @url = "/events/#{ events(:summer_camp_911_10eme).slug }/reservations"

    @event = events(:summer_camp_911_10eme)
    @event.reserve( [products(:tent_4x5_10eme), products(:cooking_plate_10eme)] )
    @event.save!

    refute products(:tent_4x5_10eme).reservations.empty?
    refute products(:cooking_plate_10eme).reservations.empty?
  end

  test "POST create with remove=1 releases an instance of the product" do
    post @url, params: {remove: "1", products: { products(:tent_4x5_10eme).slug => "1" }}
    follow_redirect!
    assert_response :success
    assert products(:tent_4x5_10eme).reload.reservations.empty?
  end

  test "POST create with remove=1 and two products releases each instance" do
    post @url, params: {remove: "1", products: { products(:cooking_plate_10eme).slug => "1", products(:tent_4x5_10eme).slug => "1" }}
    follow_redirect!
    assert_response :success
    assert products(:tent_4x5_10eme).reload.reservations.empty?
    assert products(:cooking_plate_10eme).reload.reservations.empty?
  end

  test "POST create with remove=1 and format=js and two products releases each instance" do
    post @url, params: {remove: "1", products: { products(:cooking_plate_10eme).slug => "1", products(:tent_4x5_10eme).slug => "1" }, format: :js}
    assert_response :success
    assert products(:tent_4x5_10eme).reload.reservations.empty?
    assert products(:cooking_plate_10eme).reload.reservations.empty?
  end

  test "GET index filters to products reserved for this event" do
    get @url, params: {only_show_my_reserved_products: "1", tent: "1"}

    assert_response :success
    assert_select "#desktop-only-show-my-reserved-products[checked]", count: 1
    assert_select "#desktop-category-tent[checked]", count: 1
    assert_select "#desktop-reservation-filters a.forest-filter-clear", count: 1
    assert_select "#entity-card-#{products(:tent_4x5_10eme).slug}", count: 1
    assert_select "#entity-card-#{products(:cooking_plate_10eme).slug}", count: 0
  end
end
