require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test "assigns a slug on create" do
    group = Group.create!(name: "10eme")
    assert_not_nil group.slug
  end

  test "does not change slug on update" do
    group = groups(:"10eme")
    old_slug = group.slug
    group.name = "39eme"
    group.save!

    assert_equal old_slug, group.slug
  end
end
