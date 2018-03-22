class ApplicationController < ActionController::Base

  before_action :__dev_set_user if Rails.env.development?

  private

  def current_user
    @_current_user ||= User.includes(:group).find(session[:user_id])
  end

  def current_group
    current_user.group
  end

  def __dev_set_user
    session[:user_id] ||= User.first.id
  end
end
