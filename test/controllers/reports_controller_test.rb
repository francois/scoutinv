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
    assert_select ".forest-report-index"
    assert_select ".forest-report-link", count: 2
    assert_select "h1#page-heading", text: I18n.t("reports.page_title")
    assert_select ".forest-report-index h2", count: 0
    assert_select ".forest-report-link__description", count: 2
  end

  test "GET #leased" do
    get report_path(id: "leased")
    assert_response :success
    assert_template "reports/leased"
    assert_select "table.forest-report-table"
    assert_select ".forest-report-scroll[tabindex='0'][role='region'][aria-labelledby='page-heading']"
    assert_select ".forest-report-panel h2", count: 0
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
    assert_select "table.forest-report-table"
    assert_select ".forest-report-scroll[tabindex='0'][role='region'][aria-labelledby='page-heading']"
    assert_select ".forest-report-panel h2", count: 0
    groups(:"10eme").instances.reject(&:available?).each do |instance|
      assert_select "table tr#product-#{instance.product_slug}-instance-#{instance.slug}", count: 1
    end
  end

  test "report descriptions are translated in English" do
    get reports_path(locale: :en)
    assert_response :success
    assert_select ".forest-report-link__description", text: I18n.t("reports.index.leased_description", locale: :en)
    assert_select ".forest-report-link__description", text: I18n.t("reports.index.unavailable_description", locale: :en)
  end
end
