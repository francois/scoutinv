require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  private

  def login_as(member)
    visit new_session_path
    fill_in "email", with: member.email
    click_button

    assert_current_path sessions_path

    token = member.reload.sessions.last.token
    visit session_path(token, member_id: member.slug)
  end
end
