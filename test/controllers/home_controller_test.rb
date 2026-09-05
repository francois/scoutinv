require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  test "home page renders when an anoymous person visits" do
    get "/"
    assert_response :success
    refute response.body.include?(events(:summer_camp_911_10eme).title)
    assert_select ".forest-public-home"
    assert_select "form.forest-authentication-form"
  end

  test "home page uses the forest application shell" do
    get root_path

    assert_response :success
    assert_select "body.forest"
    assert_select "link[rel='stylesheet'][href*='forest']", count: 1
    assert_select "header.forest-site-header"
    assert_select "nav.forest-primary-nav"
    assert_select "main#main-content"
    assert_select "footer.forest-site-footer"
  end

  test "home page renders when an authenticated person visits" do
    login_as(members(:baloo_10eme))
    get root_path
    assert response.body.include?(events(:summer_camp_911_10eme).title)
    assert_select ".forest-home-dashboard"
    assert_select ".forest-home-event-list"
  end
end
