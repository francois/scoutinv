ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

module LoginTestHelper
  def login_as(member)
    get new_session_path
    assert_response :success

    post sessions_path, params: {email: member.email}
    follow_redirect!
    assert_response :success
    assert_equal sessions_path, path

    session = member.sessions.first
    get session_path(session.token, member_id: member.slug)
    follow_redirect!

    assert_response :success
    assert_equal root_path, path
  end
end
