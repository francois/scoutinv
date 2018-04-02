class Products::NotesController < ApplicationController
  def create
    current_group.transaction do
      @product = current_group.products.find_by!(slug: params[:product_id])
      @product.add_note(note_params.merge(author: current_member), metadata: domain_event_metadata)
      @product.save!
    end

    redirect_to product_path(@product)
  end

  private

  def note_params
    params.require(:note).permit(:body)
  end
end
