class NotesController < ApplicationController
  def destroy
    @note = current_group.find_note_by_slug!(params[:id])
    return render text: "unauthorized", status: :unauthorized unless @note.author == current_member

    @note.destroy

    respond_to do |format|
      format.html { redirect_to @note.parent }
      format.js
    end
  end
end
