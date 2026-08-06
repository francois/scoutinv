require "test_helper"

class Dev::AuthControllerTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  test "signs in the member from the email address" do
    with_dev_auth_route do
      get "/dev/auth", params: { email: members(:baloo_10eme).email }, headers: english_headers

      assert_redirected_to root_path
      assert_equal "Authenticated as #{members(:baloo_10eme).email}", flash[:notice]

      assert_equal members(:baloo_10eme), controller.send(:current_member)
    end
  end

  test "replaces the signed-in member" do
    login_as(members(:baloo_10eme))

    with_dev_auth_route do
      get "/dev/auth", params: { email: members(:baloo_41eme).email }, headers: english_headers

      assert_equal members(:baloo_41eme), controller.send(:current_member)
    end
  end

  test "does not add the route outside development" do
    assert_not Rails.application.routes.routes.any? { |route| route.path.spec.to_s.include?("dev/auth") }
  end

  private

  def with_dev_auth_route(&)
    with_routing do |routes|
      routes.draw do
        root to: "home#show"
        get "dev/auth", to: "dev/auth#show"
      end

      yield
    end
  end

  def english_headers
    {
      "Accept-Language" => "en-US,en;q=0.9",
    }
  end
end
