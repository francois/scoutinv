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

    if params[:print].blank?
      render action: :show
    else
      render action: :print
    end
  end

  def new
    @page_title = "New Event"
    @event = Event.new
  end

  def edit
    @page_title = "Edit #{@event.title}"
  end

  def create
    current_group.transaction do
      @event = current_group.register_new_event(event_params, metadata: domain_event_metadata)

      if current_group.save
        redirect_to @event, notice: t(".event_successfully_created")
      else
        @page_title = "New Event"
        render :new
      end
    end
  end

  def update
    current_group.transaction do
      if @event.change_information(event_params, metadata: domain_event_metadata)
        redirect_to @event, notice: t(".event_successfully_updated")
      else
        @page_title = "Edit #{@event.title}"
        render :edit
      end
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: t(".event_successfully_destroyed")
  end

  private

  def set_event
    @event = current_group.events.includes(:group, notes: :author, reservations: :product).find_by!(slug: params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :start_on, :end_on)
  end
end
