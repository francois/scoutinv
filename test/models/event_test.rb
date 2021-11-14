require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "event belongs_to group" do
    assert_equal groups(:"10eme"), events(:summer_camp_911_10eme).group
    assert groups(:"10eme").events.include?(events(:summer_camp_911_10eme))
    refute groups(:"10eme").events.include?(events(:summer_camp_911_41eme))
  end

  test "assigns a slug on create" do
    event = groups(:"41eme").events.create!(title: "Summer Camp", troop: troops(:cubs_41eme), pick_up_on: Date.yesterday, start_on: Date.today, end_on: Date.today, return_on: Date.tomorrow)
    assert_not_nil event.slug
  end

  test "does not change slug on update" do
    event = events(:summer_camp_911_10eme)
    old_slug = event.slug
    event.title = "Camp d'été 9-11 (filles)"
    event.save!

    assert_equal old_slug, event.slug
  end

  test "#date_range" do
    event = events(:summer_camp_911_41eme)
    assert_equal Date.new(2018, 8, 2) .. Date.new(2018, 8, 11), event.date_range
    assert_equal Date.new(2018, 8, 6) .. Date.new(2018, 8, 10), event.real_date_range
  end
end
