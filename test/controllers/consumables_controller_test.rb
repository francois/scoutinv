require 'test_helper'

class ConsumablesControllerTest < ActionDispatch::IntegrationTest
  include LoginTestHelper

  setup do
    login_as(members(:baloo_10eme))
  end

  test "GET #index returns the list of consumables for the current_group" do
    get "/consumables"

    assert_response :success
    assert_template "consumables/index"
  end
end
