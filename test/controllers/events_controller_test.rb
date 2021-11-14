require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  setup do
    login_as(members(:baloo_10eme))
  end

  test "prints a contract for a troop event" do
    get "/events/#{events(:summer_camp_911_10eme).slug}.pdf"

    assert_response :success
    assert_equal "application/pdf", response.headers["Content-Type"]
  end

  test "prints a contract for an external event" do
    group = groups(:"10eme")
    event = group.register_new_event(
      title: "External",
      name: "Mr Smith",
      email: "john.smith@example.com",
      address: "1 Infinite Loop\nCupertino CA",
      phone: "1-800-MY-APPLE",
      pick_up_on: 4.days.from_now,
      start_on: 5.days.from_now,
      end_on: 7.days.from_now,
      return_on: 8.days.from_now
    )
    group.save!

    get "/events/#{event.slug}.pdf"

    assert_response :success
    assert_equal "application/pdf", response.headers["Content-Type"]
  end
end
