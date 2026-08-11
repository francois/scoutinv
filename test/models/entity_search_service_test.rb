require "test_helper"

class EntitySearchServiceTest < ActiveSupport::TestCase
  setup do
    @group = groups(:"10eme")
    @uncategorized_product = @group.products.create!(name: "Uncategorized product")
  end

  test "includes products without categories when no categories are selected" do
    entities = EntitySearchService.new(current_group: @group).entities

    assert_includes entities, @uncategorized_product
  end

  test "excludes products without categories when categories are selected" do
    entities = EntitySearchService.new(
      current_group: @group,
      category_ids: [categories(:tent).id],
    ).entities

    refute_includes entities, @uncategorized_product
  end
end
