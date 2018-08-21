class Events::ProductsController < ::ProductsController
  before_action :set_event

  private

  def set_event
    @event = current_group.events.find_by!(slug: params[:event_id])
  end
end
