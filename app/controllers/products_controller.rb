class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = current_group.products.by_name.all
  end

  def show
  end

  def new
    @product = current_group.products.build
  end

  def edit
  end

  def create
    @product = current_group.products.build(product_params)

    if @product.save
      redirect_to @product, notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: 'Product was successfully destroyed.'
  end

  private

  def set_product
    @product = current_group.products.find_by!(slug: params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description)
  end
end
