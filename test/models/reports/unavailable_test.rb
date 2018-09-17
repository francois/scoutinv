require "test_helper"

class Reports::UnavailableTest < ActiveSupport::TestCase
  test "with no unavailable instances" do
    Instance.update_all(state: "available")

    report = Reports::Unavailable.new(groups(:"10eme"))
    assert report.rows.empty?
  end

  test "with an unavailable instance" do
    assert_equal ["repairing"], groups(:"41eme").instances.map(&:state).uniq
    report = Reports::Unavailable.new(groups(:"41eme"))
    refute report.rows.empty?
  end
end
