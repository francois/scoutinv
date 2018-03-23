class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @after = params[:after].present? ? params[:after].to_date : 1.month.ago

    @events = current_group.events.by_date
    @events = @events.after(@after)
    @events = @events.all
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = current_group.events.build(event_params)

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render :new
    end
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully destroyed.'
  end

  private

  def set_event
    @event = current_group.events.includes(:group, reservations: :product).find_by!(slug: params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :notes, :start_on, :end_on)
  end
end
