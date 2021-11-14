require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  setup do
    @event = events(:summer_camp_911_41eme)
  end

  test "#event_overlaps? with an event that abuts before" do
    new_event = groups(:"41eme").events.build(troop: troops(:cubs_41eme), title: "foo", pick_up_on: "2018-07-29", start_on: "2018-07-30", end_on: "2018-07-31", return_on: "2018-08-01")
    assert new_event.valid?, new_event.errors.full_messages.to_sentence

    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    refute reservation.event_overlaps?(@event)
  end

  test "#event_overlaps? with an event that abuts after" do
    new_event = groups(:"10eme").events.build(troop: troops(:cubs_41eme), title: "foo", pick_up_on: "2018-08-12", start_on: "2018-08-13", end_on: "2018-08-18", return_on: "2018-08-19")
    assert new_event.valid?, new_event.errors.full_messages.to_sentence

    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    refute reservation.event_overlaps?(@event)
  end

  test "#event_overlaps? with an overlapping event, before" do
    new_event = groups(:"10eme").events.build(troop: troops(:cubs_41eme), title: "foo", pick_up_on: "2018-08-02", start_on: "2018-08-03", end_on: "2018-08-07", return_on: "2018-08-08")
    assert new_event.valid?, new_event.errors.full_messages.to_sentence

    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    assert reservation.event_overlaps?(@event)
  end

  test "#event_overlaps? with an overlapping event, after" do
    new_event = groups(:"10eme").events.build(troop: troops(:cubs_41eme), title: "foo", pick_up_on: "2018-08-08", start_on: "2018-08-09", end_on: "2018-08-12", return_on: "2018-08-13")
    assert new_event.valid?, new_event.errors.full_messages.to_sentence

    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    assert reservation.event_overlaps?(@event)
  end

  test "#event_overlaps? with an event that does not overlap" do
    new_event = groups(:"10eme").events.build(troop: troops(:cubs_41eme), title: "foo", pick_up_on: "2018-05-14", start_on: "2018-05-16", end_on: "2018-05-20", return_on: "2018-05-22")
    assert new_event.valid?, new_event.errors.full_messages.to_sentence

    reservation = new_event.reservations.build(product: products(:tent_4x5_10eme))
    refute reservation.event_overlaps?(@event)
  end
end
