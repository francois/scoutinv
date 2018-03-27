class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :load_categories, except: %i[ destroy ]

  def index
    @page_title = "Products"

    @filter = params[:filter]

    @selected_category = @categories.detect{|category| category.slug == params[:category]}

    @products   = current_group.products.by_name.with_categories
    @products   = @products.search(@filter) if @filter.present?
    @products   = @products.in_category(@selected_category) if @selected_category
    @products   = @products.all
  end

  def show
    @page_title = @product.name
  end

  def new
    @page_title = "New Product"
    @product = current_group.products.build
  end

  def edit
    @page_title = "Edit #{@product.name}"
  end

  def create
    @product = current_group.products.build(product_params)

    if @product.save
      redirect_to @product, notice: 'Product was successfully created.'
    else
      @page_title = "New Product"
      render :new
    end
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      @page_title = "Edit #{@product.name}"
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
    params.require(:product).permit(:name, :description, category_slugs: [])
  end

  def load_categories
    @categories = Category.by_name.to_a
  end
end
