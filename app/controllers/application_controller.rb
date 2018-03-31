class ApplicationController < ActionController::Base

  before_action :set_timezone
  before_action :set_locale
  before_action :authenticate_user!
  helper_method :user_signed_in?, :current_user, :current_group

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
        extract_locale_from_accept_language_header || I18n.default_locale
      end
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def authenticate_user!
    return if user_signed_in?
    redirect_to new_session_url
  end

  def sign_in_user!(user)
    session[:user_id] = user.id
  end

  def user_signed_in?
    session[:user_id].present?
  end

  def current_user
    @_current_user ||= User.includes(:group).find(session[:user_id])
  end

  def current_group
    current_user.group
  end
end
