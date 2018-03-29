class EventsController < ApplicationController
  before_action :set_event, except: [:index, :new, :create]

  def index
    @page_title = "Events"

    @after = params[:after].present? ? params[:after].to_date : 1.month.ago

    @events = current_group.events.by_date
    @events = @events.after(@after)
    @events = @events.all
  end

  def show
    @page_title = @event.title
    @note  = @event.notes.build
  end

  def print
    @page_title = "#{@event.title} (Print)"
  end

  def new
    @page_title = "New Event"
    @event = Event.new
  end

  def edit
    @page_title = "Edit #{@event.title}"
  end

  def create
    @event = current_group.events.build(event_params)

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      @page_title = "New Event"
      render :new
    end
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      @page_title = "Edit #{@event.title}"
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully destroyed.'
  end

  private

  def set_event
    @event = current_group.events.includes(:group, notes: :author, reservations: :product).find_by!(slug: params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :notes, :start_on, :end_on)
  end
end
