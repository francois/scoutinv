require "test_helper"

class ApplicationIntegrationTestCase < ActionDispatch::IntegrationTest
  def login_as(member)
    post "/sessions", params: { email: member.email }
    assert_equal 302, response.status

    follow_redirect!
    assert_equal 200, response.status
    assert_template "sessions/index"

    get "/sessions/#{ member.sessions.first.token }", params: { member_id: member.slug }
    assert_equal 302, response.status
    follow_redirect!

    assert_equal 200, response.status
    assert_template "home/authenticated"
  end
end
