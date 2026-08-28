require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  setup do
    login_as(members(:baloo_10eme))
  end

  test "GET index uses the Forest event list and filters" do
    get events_path

    assert_response :success
    assert_select "aside.forest-events-sidebar-column"
    assert_select "form.forest-events-filter-form input#after[type='date']"
    assert_select ".forest-events-filter-actions .button", count: 4
    assert_select "table.forest-events-table"
    assert_select "table.forest-events-table tr", text: /#{Regexp.escape(events(:summer_camp_911_10eme).title)}/ do
      assert_select "a.forest-event-row-link[href='#{event_path(events(:summer_camp_911_10eme))}']", count: 4
    end
  end

  test "GET show uses Forest event details and keeps reservation controls" do
    event = events(:summer_camp_911_10eme)

    get event_path(event)

    assert_response :success
    assert_select ".forest-event-summary", text: /#{Regexp.escape(event.title)}/
    assert_select ".forest-event-materials"
    assert_select ".forest-event-actions" do
      assert_select "a[href='#{event_reservations_path(event)}']"
      assert_select "a[href='#{edit_event_path(event)}']"
    end
  end

  test "GET new and edit use the Forest event form" do
    get new_event_path

    assert_response :success
    assert_select "form.forest-event-form"
    assert_select ".forest-form-section", count: 3

    get edit_event_path(events(:summer_camp_911_10eme))

    assert_response :success
    assert_select "form.forest-event-form"
    assert_select "#event_title", value: events(:summer_camp_911_10eme).title
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
