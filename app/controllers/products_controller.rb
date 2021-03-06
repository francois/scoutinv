class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :convert]
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

      @attached = []
      @attached.concat(@product.images.attach(params[:product][:images])) if params[:product][:images].present?
      @attached.concat(import(params[:product][:image_url]))

      if params[:clone_from].present?
        @clone_from = current_group.products.find_by!(slug: params[:clone_from])
        @clone_from.images.each do |attachment|
          @product.images.build(blob: attachment.blob)
        end
      end

      current_group.save.tap do
        @attached.each do |image|
          ShrinkImageJob.enqueue(@product.id, image.id)
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

      @attached = []
      @attached.concat(@product.images.attach(params[:product][:images])) if params[:product][:images].present?
      @attached.concat(import(params[:product][:image_url]))

      @product.save.tap do
        @attached.each do |image|
          ShrinkImageJob.enqueue(@product.id, image.id)
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

  def convert
    group = @product.group
    consumable = nil
    Group.transaction do
      consumable = group.convert_product_to_consumable(@product.slug, t(".conversion_reason"), metadata: domain_event_metadata)
      group.save!
      consumable.images.each do |image|
        ShrinkImageJob.enqueue(consumable.id, image.id)
      end
    end

    redirect_to consumable, notice: t(".product_successfully_converted")
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

  def import(image_url)
    return [] if image_url.blank?

    uri = URI.parse(image_url)

    response = Net::HTTP.get_response(uri)

    @product.images.attach(
      io: StringIO.new(response.body),
      filename: File.basename(uri.path),
      content_type: response["Content-Type"],
    )
  end
end
