require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  setup do
    login_as(members(:akela_10eme))
  end

  test "GET #index" do
    get reports_path
    assert_response :success
    assert_template "reports/index"
  end

  test "GET #leased" do
    get report_path(id: "leased")
    assert_response :success
    assert_template "reports/leased"
    assert_select "table tr td[colspan]"
  end

  test "GET #leased with leased product" do
    event = events(:summer_camp_911_10eme)
    event.reserve([products(:tent_4x5_10eme)])
    event.lease_all
    event.save!

    get report_path(id: "leased")
    assert_response :success
    assert_template "reports/leased"
    assert_select "table tr#product-#{event.reservations.first.product.slug}-instance-#{event.reservations.first.instance.slug}", count: 1
  end

  test "GET #unavailable with unavailable products" do
    get report_path(id: "unavailable")
    assert_response :success
    assert_template "reports/unavailable"
    groups(:"10eme").instances.reject(&:available?).each do |instance|
      assert_select "table tr#product-#{instance.product_slug}-instance-#{instance.slug}", count: 1
    end
  end
end
