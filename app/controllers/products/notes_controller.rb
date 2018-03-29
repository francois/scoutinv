class Products::NotesController < ApplicationController
  def create
    @product = current_group.products.find_by!(slug: params[:product_id])
    @product.notes.create(note_params.merge(author: current_user))

    redirect_to product_path(@product)
  end

  private

  def note_params
    params.require(:note).permit(:body)
  end
end
