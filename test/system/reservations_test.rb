require "application_system_test_case"

class ReservationsTest < ApplicationSystemTestCase
  setup do
    @member = members(:baloo_10eme)
    @event = events(:summer_camp_911_10eme)
    @product = products(:tent_4x5_10eme)
  end

  test "member signs in with the email link" do
    login_as(@member)

    assert_current_path root_path
    assert_link @event.title, href: event_path(@event)
  end

  test "member adds an available product to an event" do
    login_as(@member)
    visit event_reservations_path(@event)

    within "#entity-card-#{@product.slug}" do
      click_button "+1"
      assert_button "-1", disabled: false
    end

    assert_equal 1, @event.reload.reservations_of(@product).size
  end

  test "member sees a warning when reserving a product on overlapping events" do
    login_as(@member)

    pick_up_on = Date.current + 3.weeks
    first_event_title = "First future camp"
    first_event_path = create_event(title: first_event_title, pick_up_on: pick_up_on)

    visit events_path
    assert_link first_event_title, href: first_event_path

    visit "#{first_event_path}/reservations"
    within "#entity-card-#{@product.slug}" do
      click_button "+1"
      assert_button "-1", disabled: false
    end

    overlapping_event_path = create_event(title: "Overlapping future camp", pick_up_on: pick_up_on + 2.days)
    visit "#{overlapping_event_path}/reservations"

    within "#entity-card-#{@product.slug}" do
      click_button "+1"
    end

    assert_selector "#notices .callout.alert", text: I18n.t("events.reservations.create.double_booking_error_alert")
  end

  private

  def create_event(title:, pick_up_on:)
    visit new_event_path
    fill_in "event_title", with: title
    select troops(:cubs_10eme).name, from: "event_troop_id"
    fill_in "event_pick_up_on", with: pick_up_on.strftime("%d/%m/%Y")
    fill_in "event_start_on", with: (pick_up_on + 1.day).strftime("%d/%m/%Y")
    fill_in "event_end_on", with: (pick_up_on + 3.days).strftime("%d/%m/%Y")
    fill_in "event_return_on", with: (pick_up_on + 4.days).strftime("%d/%m/%Y")
    find("form[action='#{events_path}'] input[type='submit']").click

    assert_selector "h1", text: title
    current_path
  end
end
