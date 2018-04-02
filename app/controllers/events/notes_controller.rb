class Events::NotesController < ApplicationController
  def create
    current_group.transaction do
      @event = current_group.events.find_by!(slug: params[:event_id])
      @event.add_note(note_params.merge(author: current_member), metadata: domain_event_metadata)
      @event.save!
    end

    redirect_to event_path(@event)
  end

  private

  def note_params
    params.require(:note).permit(:body)
  end
end
