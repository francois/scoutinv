class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ index new create show ]

  def index
    render
  end

  def new
    render
  end

  def create
    reset_session
    user = User.find_by!(email: params[:email])
    token = user.create_session_token!
    UserMailer.send_authentication(user.email, session_url(token, user_id: user.slug)).deliver_now

    redirect_to sessions_path
  rescue ActiveRecord::RecordNotFound
    redirect_to new_session_path, alert: "Unknown email address"
  end

  def show
    reset_session
    user = User.authenticate!(slug: params[:user_id], token: params[:id])
    user.delete_pending_sessions
    session[:user_id] = user.id
    redirect_to products_path, notice: "Welcome!"
  rescue ActiveRecord::RecordNotFound
    redirect_to new_session_path, alert: "Failed to authenticate"
  end

  def destroy
    reset_session
    redirect_to new_session_path
  end
end
