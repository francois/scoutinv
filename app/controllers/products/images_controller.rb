class Products::ImagesController < ApplicationController
  def destroy
    product = current_group.products.find_by!(slug: params[:product_id])
    product.images.find(params[:id]).destroy
    redirect_to product, notice: I18n.t("products.images.destroy.notice")
  end
end
