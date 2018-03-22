require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user belongs_to group" do
    assert_equal groups(:"10eme"), users(:baloo_10eme).group
    assert groups(:"10eme").users.include?(users(:baloo_10eme))
    refute groups(:"10eme").users.include?(users(:baloo_41eme))
  end
end
