require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  setup do
    @event = events(:summer_camp_911_41eme)
  end

  test "#dates_overlap? with an event that abuts before" do
    new_event = groups(:"41eme").events.build(start_on: "2018-08-01", end_on: "2018-08-03")
    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    refute reservation.dates_overlap?(@event)
  end

  test "#dates_overlap? with an event that abuts after" do
    new_event = groups(:"10eme").events.build(start_on: "2018-08-13", end_on: "2018-08-18")
    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    refute reservation.dates_overlap?(@event)
  end

  test "#dates_overlap? with an overlapping event, before" do
    new_event = groups(:"10eme").events.build(start_on: "2018-08-03", end_on: "2018-08-07")
    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    assert reservation.dates_overlap?(@event)
  end

  test "#dates_overlap? with an overlapping event, after" do
    new_event = groups(:"10eme").events.build(start_on: "2018-08-09", end_on: "2018-08-12")
    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    assert reservation.dates_overlap?(@event)
  end

  test "#dates_overlap? with an event that does not overlap" do
    new_event = groups(:"10eme").events.build(start_on: "2018-05-16", end_on: "2018-05-20")
    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    refute reservation.dates_overlap?(@event)
  end
end
