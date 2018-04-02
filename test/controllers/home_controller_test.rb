require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "home page renders when an anoymous person visits" do
    get "/"
    assert_response :success
    refute response.body.include?(events(:summer_camp_911_10eme).title)
  end

  test "home page renders when an authenticated person visits" do
    get new_session_path
    assert_response :success

    post sessions_path, params: {email: members(:baloo_10eme).email}
    follow_redirect!
    assert_response :success
    assert_equal sessions_path, path

    session = members(:baloo_10eme).sessions.first
    get session_path(session.token, member_id: members(:baloo_10eme).slug)
    follow_redirect!

    assert_response :success
    assert_equal root_path, path
    assert response.body.include?(events(:summer_camp_911_10eme).title)
  end
end
