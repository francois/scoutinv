require "application_system_test_case"

class ConsumablesTest < ApplicationSystemTestCase
  setup do
    @member = members(:akela_10eme)
  end

  test "inventory director adds a consumable image and rotates it" do
    create_consumable(
      name: "Portrait image consumable",
      images: [image_file(width: 20, height: 30, color: "red")],
    )

    assert_selector ".entity-image", count: 1
    image_card_id = find(".entity-image")[:id]

    within "##{image_card_id}" do
      find("form[action$='/right'] button").click
    end

    assert_no_selector "##{image_card_id}"
    assert_selector ".entity-image", count: 1
    refute_equal image_card_id, find(".entity-image")[:id]
  end

  test "inventory director adds several consumable images at once" do
    create_consumable(
      name: "Multiple images consumable",
      images: [
        image_file(width: 20, height: 30, color: "red"),
        image_file(width: 30, height: 20, color: "blue"),
      ],
    )

    assert_selector ".entity-image", count: 2
  end

  private

  def create_consumable(name:, images:)
    login_as(@member)
    visit new_consumable_path

    fill_in "consumable_name", with: name
    fill_in "consumable_base_quantity", with: "1 unit"
    attach_file "consumable_images", images
    click_button I18n.t("helpers.submit.create", model: Consumable.model_name.human)
  end
end
