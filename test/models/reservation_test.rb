require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  test "reservation belongs_to group" do
    assert_equal groups(:"10eme"), reservations(:summer_camp_911_10eme).group
    assert groups(:"10eme").reservations.include?(reservations(:summer_camp_911_10eme))
    refute groups(:"10eme").reservations.include?(reservations(:summer_camp_911_41eme))
  end

  test "assigns a slug on create" do
    reservation = groups(:"41eme").reservations.create!(title: "Summer Camp", start_on: Date.today, end_on: Date.today)
    assert_not_nil reservation.slug
  end

  test "does not change slug on update" do
    reservation = reservations(:summer_camp_911_10eme)
    old_slug = reservation.slug
    reservation.title = "Camp d'été 9-11 (filles)"
    reservation.save!

    assert_equal old_slug, reservation.slug
  end
end
