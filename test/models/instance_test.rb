require "test_helper"

class InstanceTest < ActiveSupport::TestCase
  setup do
    assert_equal 4, Instance.count
    @instance = products(:cooking_plate_10eme).instances.first
    assert_not_nil @instance
  end

  test "state machine" do
    @instance.hold
    assert @instance.held?

    @instance.send_for_repairs
    assert @instance.repairing?

    @instance.repair
    assert @instance.available?

    @instance.trash
    assert @instance.trashed?
    assert_raises{ @instance.hold! }
  end
end
