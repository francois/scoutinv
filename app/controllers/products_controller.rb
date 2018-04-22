class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :load_categories, except: %i[ destroy ]

  def index
    @page_title = t(".page_title")

    @filter = params[:filter]

    @selected_category = @categories.detect{|category| category.slug == params[:category]}

    @products = current_group.products.with_attached_images.with_categories
    @products = @products.search(@filter) if @filter.present?
    @products = @products.in_category(@selected_category) if @selected_category
    @products = @products.by_name
    @products = @products.page(params[:page])
  end

  def show
    @page_title = @product.name
    @note = @product.notes.build
  end

  def new
    @page_title = t(".page_title")
    @product =
      if params[:clone_from].present?
        @clone_from = current_group.products.find_by!(slug: params[:clone_from])
        current_group.products.build(
          aisle: @clone_from.aisle,
          categories: @clone_from.categories,
          description: @clone_from.description,
          images: @clone_from.images,
          name: @clone_from.name,
          shelf: @clone_from.shelf,
          unit: @clone_from.unit,
        )
      else
        current_group.products.build
      end
  end

  def edit
    @page_title = t(".page_title", product_name: @product.name)
  end

  def create
    current_group.transaction do
      @product = current_group.register_new_product(product_params, metadata: domain_event_metadata)
      @product.images.attach(params[:product][:images]) if params[:product][:images].present?
      if params[:clone_from].present?
        @clone_from = current_group.products.find_by!(slug: params[:clone_from])
        @clone_from.images.each do |attachment|
          @product.images.build(blob: attachment.blob)
        end
      end

      if current_group.save
        redirect_to @product, notice: t(".product_successfully_created")
      else
        @page_title = "New Product"
        render :new
      end
    end
  end

  def update
    current_group.transaction do
      @product.change_data(product_params, metadata: domain_event_metadata)
      @product.images.attach(params[:product][:images]) if params[:product][:images].present?

      if @product.save
        redirect_to @product, notice: t(".product_successfully_updated")
      else
        @page_title = "Edit #{@product.name}"
        render :edit
      end
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: t(".product_successfully_destroyed")
  end

  private

  def set_product
    @product = current_group.products.find_by!(slug: params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :aisle, :shelf, :unit, category_slugs: [])
  end

  def load_categories
    @categories = Category.by_name.to_a
  end
end
