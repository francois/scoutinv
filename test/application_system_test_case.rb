require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  setup do
    @system_test_images = []
  end

  teardown do
    @system_test_images.each { |path| File.delete(path) if File.exist?(path) }
  end

  private

  def login_as(member)
    visit new_session_path
    fill_in "email", with: member.email
    click_button

    assert_current_path sessions_path

    token = member.reload.sessions.last.token
    visit session_path(token, member_id: member.slug)
  end

  def image_file(width:, height:, color:)
    Rails.root.join("tmp", "system-test-image-#{SecureRandom.uuid}.jpg").tap do |path|
      MiniMagick.convert do |convert|
        convert.size "#{width}x#{height}"
        convert.xc color
        convert << path
      end

      @system_test_images << path
    end
  end
end
