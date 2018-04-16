class ApplicationController < ActionController::Base

  before_action :set_timezone
  before_action :set_locale
  before_action :authenticate_member!
  helper_method :member_signed_in?, :current_member, :current_group

  skip_before_action :verify_authenticity_token

  private

  def set_timezone
    Time.zone = "America/Montreal"
  end

  def set_locale
    I18n.locale =
      case
      when params[:locale] == "fr"
        :fr
      when params[:locale] == "en"
        :en
      else
        locale = extract_locale_from_accept_language_header || I18n.default_locale
        case locale.to_s
        when "fr"
          :fr
        when "en"
          :en
        else
          :en
        end
      end
  end

  def extract_locale_from_accept_language_header
    return nil if request.env['HTTP_ACCEPT_LANGUAGE'].blank?
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def authenticate_member!
    return if member_signed_in?
    redirect_to new_session_url
  end

  def sign_in_member!(member)
    session[:member_id] = member.id
  end

  def member_signed_in?
    session[:member_id].present?
  end

  def current_member
    @_current_member ||= Member.includes(:group).find(session[:member_id])
  end

  def current_group
    current_member.group
  end

  def domain_event_metadata
    {
      current_group: current_group.slug,
      current_member: current_member.slug,
      remote_ip: request.remote_ip,
      request_id: request.request_id,
      user_agent: request.env["HTTP_USER_AGENT"],
    }
  end
end
