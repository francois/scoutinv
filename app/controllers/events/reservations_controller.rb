class Events::ReservationsController < ApplicationController
  before_action :set_event

  def index
    @page_title = I18n.t("events.reservations.index.page_title", event: @event.title)

    @filter = params[:filter]
    @only_show_available_products   = params[:only_show_available_products]   == "1"
    @only_show_leased_products      = params[:only_show_leased_products]      == "1"
    @only_show_reserved_products    = params[:only_show_reserved_products]    == "1"
    @only_show_my_reserved_products = params[:only_show_my_reserved_products] == "1"

    @categories = Category.by_name.to_a
    @selected_category = @categories.detect{|category| category.slug == params[:category]}

    @products     = current_group.products.with_attached_images.with_categories.with_reservations
    @products     = @products.search(@filter)                 if @filter.present?
    @products     = @products.in_category(@selected_category) if @selected_category
    @products     = @products.available                       if @only_show_available_products
    @products     = @products.leased                          if @only_show_leased_products
    @products     = @products.reserved                        if @only_show_reserved_products
    @products     = @products.reserved(@event)                if @only_show_my_reserved_products
    @products     = @products.by_name
    @products     = @products.page(params[:page])

    @reservations = @event.reservations.with_product.all
    @double_booked_products = Product.double_booked(@event).to_set
  end

  def create
    return redirect_to(action: :index) if params[:products].blank? && params[:lease_all].blank?

    current_group.transaction do
      if params[:products].present?
        @products = current_group.products.includes(reservations: [:event, :instance]).where(slug: params[:products].keys).to_a
      end

      if %i[ add remove lease lease_all return ].all?{|key| params[key].blank?}
        # NOP
      elsif params[:add].present?
        @event.add(@products, metadata: domain_event_metadata)
        flash[:notice] = t(:added, scope: "events.reservations.create", num: @products.size)
      elsif params[:remove].present?
        @event.remove(@products, metadata: domain_event_metadata)
        flash[:notice] = t(:removed, scope: "events.reservations.create", num: @products.size)
      elsif params[:lease].present?
        @event.lease(@products, metadata: domain_event_metadata)
        flash[:notice] = t(:leased, scope: "events.reservations.create", num: @products.size)
      elsif params[:lease_all].present?
        @event.lease_all(metadata: domain_event_metadata)
        flash[:notice] = t(:leased_all, scope: "events.reservations.create", num: @event.reservations.size)
      elsif params[:return].present?
        @event.return(@products, metadata: domain_event_metadata)
        flash[:notice] = t(:returned, scope: "events.reservations.create", num: @products.size)
      else
        raise "ASSERTION ERROR: One of add and remove were supposed to be filled in, none were?!?"
      end

      @event.save!
    end

    respond_to do |format|
      format.html do
        if params[:back_to_event].blank?
          redirect_to action: :index
        else
          redirect_to event_path(@event)
        end
      end

      format.js do
        @double_booked_products = Product.double_booked(@event).to_set

        # We must reload products because we worked on the event's products instead
        # This is a limitation of the ActiveRecord implementation
        @products = current_group.products.includes(reservations: [:event, :instance]).where(slug: params[:products].keys).to_a

        # Don't prepare a flash, because we won't need to show it: the UI updates
        # immediately and the end-user can't be surprised. What would be surprising
        # is getting a flash message when they navigate away from the page.
        flash[:notice] = nil

        render
      end
    end
  end

  private

  def set_event
    @event = current_group.events.includes(reservations: [:instance, :product]).find_by!(slug: params[:event_id])
  end
end
