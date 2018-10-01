class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :load_categories, except: %i[ destroy ]

  def index
    @page_title = t(".page_title")

    @filter = params[:filter]

    @selected_category = @categories.detect{|category| category.slug == params[:category]}

    @products = current_group.products.with_attached_images.with_categories.with_instances
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
          building: @clone_from.building,
          categories: @clone_from.categories,
          description: @clone_from.description,
          quantity: @clone_from.quantity,
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
    successful = current_group.transaction do
      @product = current_group.register_new_product(product_params, metadata: domain_event_metadata)
      @attached = @product.images.attach(params[:product][:images]) if params[:product][:images].present?
      if params[:clone_from].present?
        @clone_from = current_group.products.find_by!(slug: params[:clone_from])
        @clone_from.images.each do |attachment|
          @product.images.build(blob: attachment.blob)
        end
      end

      current_group.save.tap do
        @attached.each do |image|
          ShrinkImageJob.perform_later(@product, image)
        end if @attached
      end
    end

    if successful
      redirect_to @product, notice: t(".product_successfully_created")
    else
      @page_title = "New Product"
      render :new
    end
  end

  def update
    successful = current_group.transaction do
      @product.change_data(product_params, metadata: domain_event_metadata)
      @attached = @product.images.attach(params[:product][:images]) if params[:product][:images].present?

      @product.save.tap do
        @attached.each do |image|
          ShrinkImageJob.perform_later(@product, image)
        end if @attached
      end
    end

    if successful
      redirect_to @product, notice: t(".product_successfully_updated")
    else
      @page_title = "Edit #{@product.name}"
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: t(".product_successfully_destroyed")
  end

  private

  def set_product
    @product = current_group.products.with_reservations.find_by!(slug: params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :building,
      :aisle,
      :shelf,
      :unit,
      :quantity,
      :internal_unit_price,
      :external_unit_price,
      category_slugs: [],
    )
  end

  def load_categories
    @categories = Category.by_name.to_a
  end
end
