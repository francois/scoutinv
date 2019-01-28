class ConsumablesController < ApplicationController
  before_action :set_consumable, only: [:show, :edit, :update, :destroy]
  before_action :load_categories, except: %i[ destroy ]

  def index
    @page_title = t(".page_title")

    @filter = params[:filter]

    @selected_category = @categories.detect{|category| category.slug == params[:category]}

    @consumables = current_group.consumables.with_attached_images.with_categories
    @consumables = @consumables.search(@filter) if @filter.present?
    @consumables = @consumables.in_category(@selected_category) if @selected_category
    @consumables = @consumables.by_name
    @consumables = @consumables.page(params[:page])
  end

  def show
    @page_title = @consumable.name
    @note = @consumable.notes.build
    @consumable_transaction = @consumable.consumable_transactions.build(quantity: Quantity.zero(@consumable.unit))
  end

  def new
    @page_title = t(".page_title")
    @consumable =
      if params[:clone_from].present?
        @clone_from = current_group.consumables.find_by!(slug: params[:clone_from])
        current_group.consumables.build(
          aisle: @clone_from.aisle,
          building: @clone_from.building,
          categories: @clone_from.categories,
          description: @clone_from.description,
          images: @clone_from.images,
          name: @clone_from.name,
          shelf: @clone_from.shelf,
          unit: @clone_from.unit,
        )
      else
        current_group.consumables.build
      end
  end

  def edit
    @page_title = t(".page_title", consumable_name: @consumable.name)
  end

  def create
    successful = current_group.transaction do
      @consumable = current_group.register_new_consumable(consumable_params, metadata: domain_event_metadata)

      @attached = []
      @attached.concat(@consumable.images.attach(params[:consumable][:images])) if params[:consumable][:images].present?
      @attached.concat(import(params[:consumable][:image_url]))

      if params[:clone_from].present?
        @clone_from = current_group.consumables.find_by!(slug: params[:clone_from])
        @clone_from.images.each do |attachment|
          @consumable.images.build(blob: attachment.blob)
        end
      end

      current_group.save.tap do
        @attached.each do |image|
          ShrinkImageJob.perform_later(@consumable, image)
        end if @attached
      end
    end

    if successful
      redirect_to @consumable, notice: t(".consumable_successfully_created")
    else
      @page_title = "New Consumable"
      render :new
    end
  end

  def update
    successful = current_group.transaction do
      @consumable.change_data(consumable_params, metadata: domain_event_metadata)

      @attached = []
      @attached.concat(@consumable.images.attach(params[:consumable][:images])) if params[:consumable][:images].present?
      @attached.concat(import(params[:consumable][:image_url]))

      @consumable.save.tap do
        @attached.each do |image|
          ShrinkImageJob.perform_later(@consumable, image)
        end if @attached
      end
    end

    if successful
      redirect_to @consumable, notice: t(".consumable_successfully_updated")
    else
      @page_title = "Edit #{@consumable.name}"
      render :edit
    end
  end

  def destroy
    @consumable.destroy
    redirect_to consumables_url, notice: t(".consumable_successfully_destroyed")
  end

  private

  def set_consumable
    @consumable = current_group.consumables.find_by!(slug: params[:id])
  end

  def consumable_params
    params.require(:consumable).permit(
      :name,
      :description,
      :building,
      :aisle,
      :shelf,
      :unit,
      :internal_unit_price,
      :external_unit_price,
      category_slugs: [],
    ).tap do |allowed|
      parsed_quantity = QuantityParser.new.parse(params.require(:consumable).require(:base_quantity))
      allowed[:base_quantity] = parsed_quantity
    end
  end

  def load_categories
    @categories = Category.by_name.to_a
  end

  def import(image_url)
    return [] if image_url.blank?

    uri = URI.parse(image_url)

    response = Net::HTTP.get_response(uri)

    @consumable.images.attach(
      io: StringIO.new(response.body),
      filename: File.basename(uri.path),
      content_type: response["Content-Type"],
    )
  end
end
