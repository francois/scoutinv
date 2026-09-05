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
    assert_select ".forest-group-avatar[aria-hidden='true'] span", text: members(:baloo_10eme).group.name.first.upcase
    assert_select "h1#page-heading", count: 1
  end

  test "anonymous home page follows the requested locale" do
    { "fr" => "Qu'est-ce que Scoutinv?", "en" => "What is Scoutinv?" }.each do |locale, heading|
      get "/", params: { locale: locale }

      assert_response :success
      assert_select "#public-home-heading", text: heading
      assert_select ".forest-authentication-form input[type='email']", minimum: 1
    end
  end
end
