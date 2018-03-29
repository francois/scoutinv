class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ index new create show ]

  def index
    @page_title = "Authenticating"
    render
  end

  def new
    @page_title = "Authenticate"
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
    sign_in_user!(user)

    next_event = user.group.events.after(Date.today + 1).first
    if next_event
      remaining_days = next_event.date_range.first - Date.today
      case remaining_days
      when 0
        extra = "Today is the day! #{next_event.title} starts!"
      when 1
        extra = "#{next_event.title} starts tomorrow!"
      when 2..15
        extra = "Only #{remaining_days.to_i} days left until #{next_event.title} starts"
      else
        extra = "There are #{remaining_days.to_i} days until #{next_event.title} starts"
      end
    end

    redirect_to root_path, notice: "Welcome! #{extra}"
  rescue ActiveRecord::RecordNotFound
    redirect_to new_session_path, alert: "Failed to authenticate"
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
