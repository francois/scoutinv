class Consumables::NotesController < ApplicationController
  def create
    current_group.transaction do
      @consumable = current_group.consumables.find_by!(slug: params[:consumable_id])
      @consumable.add_note(note_params.merge(author: current_member), metadata: domain_event_metadata)
      @consumable.save!
    end

    redirect_to consumable_path(@consumable)
  end

  private

  def note_params
    params.require(:note).permit(:body)
  end
end
