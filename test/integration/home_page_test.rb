require "test_helper"
require "application_integration_test_case"

class HomePageTest < ApplicationIntegrationTestCase
  test "anonymous visitor" do
    get "/"

    assert_equal 200, response.status
    assert_template "home/anonymous"
  end

  test "authenticated visitor" do
    login_as members(:baloo_10eme)

    get "/events"
    assert_equal 200, response.status
    assert_template "events/index"
  end
end
