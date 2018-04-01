class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ index new create show ]

  def index
    @page_title = t(".page_title")
    render
  end

  def new
    @page_title = t(".page_title")
    render
  end

  def create
    reset_session
    user = User.find_by!(email: params[:email])
    token = user.create_session_token!
    UserMailer.send_authentication(user.email, session_url(token, user_id: user.slug)).deliver_now

    redirect_to sessions_path
  rescue ActiveRecord::RecordNotFound
    redirect_to new_session_path, alert: t(".unknown_email_address")
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
        extra = t(".event_starts_today", event_title: next_event.title)
      when 1
        extra = t(".event_starts_tomorrow", event_title: next_event.title)
      when 2..15
        extra = t(".event_starts_shortly", event_title: next_event.title, remaining_days: remaining_days.to_i)
      else
        extra = t(".event_starts_in_the_future", event_title: next_event.title, remaining_weeks: (remaining_days / 7).floor)
      end
    end

    redirect_to root_path, notice: t(".welcome", extra: extra)
  rescue ActiveRecord::RecordNotFound
    redirect_to new_session_path, alert: t(".failed_to_authenticate")
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
