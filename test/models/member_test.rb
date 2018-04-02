require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  test "member belongs_to group" do
    assert_equal groups(:"10eme"), members(:baloo_10eme).group
    assert groups(:"10eme").members.include?(members(:baloo_10eme))
    refute groups(:"10eme").members.include?(members(:baloo_41eme))
  end
end
