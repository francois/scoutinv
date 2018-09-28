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
end
