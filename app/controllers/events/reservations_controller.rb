class Events::ReservationsController < ApplicationController
  before_action :set_event

  def index
    @page_title = "Reservations for #{@event.title}"

    @filter = params[:filter]
    @only_show_reserved_products = params[:only_show_reserved_products] == "1"

    @categories = Category.by_name.to_a
    @selected_category = @categories.detect{|category| category.slug == params[:category]}

    @products     = current_group.products.with_attached_images.with_categories.with_reservations.by_name
    @products     = @products.search(@filter) if @filter.present?
    @products     = @products.in_category(@selected_category) if @selected_category
    @products     = @products.all
    @reservations = @event.reservations.with_product.all
    reserved_products = @reservations.map(&:product)

    @products = @products.select{|product| reserved_products.include?(product)} if @only_show_reserved_products
  end

  def create
    current_group.transaction do
      products = current_group.products.where(slug: params[:products].keys).to_a

      if %i[ add remove lease lease_all return ].all?{|key| params[key].blank?}
        # NOP
      elsif params[:add].present?
        @event.add(products, metadata: domain_event_metadata)
      elsif params[:remove].present?
        @event.remove(products, metadata: domain_event_metadata)
      elsif params[:lease].present?
        @event.lease(products, metadata: domain_event_metadata)
      elsif params[:lease_all].present?
        @event.lease_all(metadata: domain_event_metadata)
      elsif params[:return].present?
        @event.return(products, metadata: domain_event_metadata)
      else
        raise "ASSERTION ERROR: One of add and remove were supposed to be filled in, none were?!?"
      end

      @event.save!
    end

    redirect_to action: :index
  end

  private

  def set_event
    @event = current_group.events.find_by!(slug: params[:event_id])
  end
end
