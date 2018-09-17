require "test_helper"

class Reports::LeasedTest < ActiveSupport::TestCase
  test "without any leased instances" do
    report = Reports::Leased.new(groups(:"10eme"))
    assert report.rows.empty?
  end

  test "with a leased instance" do
    event = events(:summer_camp_911_10eme)
    event.reserve([products(:tent_4x5_10eme)])
    event.lease_all
    event.save!

    report = Reports::Leased.new(groups(:"10eme"))
    refute report.rows.empty?
    assert_equal 1, report.rows.size
  end
end
