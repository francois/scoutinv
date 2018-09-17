require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  test "home page renders when an anoymous person visits" do
    get "/"
    assert_response :success
    refute response.body.include?(events(:summer_camp_911_10eme).title)
  end

  test "home page renders when an authenticated person visits" do
    login_as(members(:baloo_10eme))
    get root_path
    assert response.body.include?(events(:summer_camp_911_10eme).title)
  end
end
