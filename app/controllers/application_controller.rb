class ApplicationController < ActionController::Base

  before_action :authenticate_user!
  helper_method :user_signed_in?, :current_user, :current_group

  private

  def authenticate_user!
    return if user_signed_in?
    redirect_to new_session_url
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
