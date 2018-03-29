class Events::NotesController < ApplicationController
  def create
    @event = current_group.events.find_by!(slug: params[:event_id])
    @event.notes.create(note_params.merge(author: current_user))

    redirect_to event_path(@event)
  end

  private

  def note_params
    params.require(:note).permit(:body)
  end
end
