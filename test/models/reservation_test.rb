require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  test "#dates_overlap? with an event that abuts before" do
    event = events(:summer_camp_911_10eme)
    new_event = groups(:"10eme").events.build(start_on: "2018-08-05", end_on: "2018-08-06")
    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    refute reservation.dates_overlap?(event)
  end

  test "#dates_overlap? with an event that abuts after" do
    event = events(:summer_camp_911_10eme)
    new_event = groups(:"10eme").events.build(start_on: "2018-08-17", end_on: "2018-08-20")
    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    refute reservation.dates_overlap?(event)
  end

  test "#dates_overlap? with an overlapping event, before" do
    event = events(:summer_camp_911_10eme)
    new_event = groups(:"10eme").events.build(start_on: "2018-08-04", end_on: "2018-08-09")
    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    assert reservation.dates_overlap?(event)
  end

  test "#dates_overlap? with an overlapping event, after" do
    event = events(:summer_camp_911_10eme)
    new_event = groups(:"10eme").events.build(start_on: "2018-08-15", end_on: "2018-08-20")
    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    assert reservation.dates_overlap?(event)
  end

  test "#dates_overlap? with an event that does not overlap" do
    event = events(:summer_camp_911_10eme)
    new_event = groups(:"10eme").events.build(start_on: "2018-05-16", end_on: "2018-05-20")
    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    refute reservation.dates_overlap?(event)
  end
end
