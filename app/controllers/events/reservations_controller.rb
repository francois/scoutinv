class Events::ReservationsController < ApplicationController
  before_action :set_event

  def index
    @page_title = I18n.t("events.reservations.index.page_title", event: @event.title)

    @double_booked_products = Product.double_booked(@event).to_set

    if current_member.inventory_director
      if params[:manage].blank?
        render_regular
      else
        render_manage
      end
    else
      if params[:manage].blank?
        render_regular
      else
        redirect_to action: :index
      end
    end
  end

  def create
    if current_member.inventory_director?
      # NOP
    elsif @event.can_change_reservations?(current_member)
      # NOP
    else
      # Cannot change reservations
      respond_to do |format|
        format.html do
          if params[:back_to_event].present?
            redirect_to event_path(@event), alert: t(".cannot_change_reservations_alert")
          elsif params[:back_to_manage].present?
            redirect_to event_reservations_path(@event, manage: 1), alert: t(".cannot_change_reservations_alert")
          else
            redirect_to action: :index, alert: t(".cannot_change_reservations_alert")
          end
        end

        format.js do
          @double_booked_products = Product.double_booked(@event).to_set

          # We must reload products because we worked on the event's products instead
          # This is a limitation of the ActiveRecord implementation
          if params[:products].present?
            @products = current_group.products.includes(reservations: [:event, :instance]).where(slug: params[:products].keys).to_a
          end

          if params[:instances].present?
            @instances = current_group.instances.includes(reservations: :product).where(serial_no: params[:instances].keys).to_a
            @products  = @instances.map(&:product).uniq
          end

          @reservations = @event.reservations.with_product.page(params[:page])

          # Don't prepare a flash, because we won't need to show it: the UI updates
          # immediately and the end-user can't be surprised. What would be surprising
          # is getting a flash message when they navigate away from the page.
          flash[:notice] = nil
          flash[:alert]  = t(".cannot_change_reservations_alert")

          render
        end
      end

      return # prevent double render errors
    end

    current_group.transaction do
      if params[:products].present?
        @products = current_group.products.includes(reservations: [:event, :instance]).where(slug: params[:products].keys).to_a
      end

      if params[:instances].present?
        @instances = current_group.instances.includes(reservations: :product).where(serial_no: params[:instances].keys).to_a
      end

      if params[:consumables].present?
        @consumables = current_group.consumables.includes(consumable_transactions: []).where(slug: params[:consumables].keys).to_a
      end

      if %i[ add consume remove lease lease_all hold return switch ].all?{|key| params[key].blank?}
        # NOP
      elsif params[:consume].present?
        logger.info "Consuming #{@consumables.size} consumables"
        parser = QuantityParser.new
        objects = @consumables.map{|c| [c, parser.parse(params[:consumables].fetch(c.slug))]}.to_h
        @event.consume(objects, metadata: domain_event_metadata)
        flash[:notice] = t(:consumed, scope: "events.reservations.create", num: @consumables.size)
      elsif params[:add].present?
        logger.info "Adding #{@products.size} products"
        @event.reserve(@products, metadata: domain_event_metadata)
        flash[:notice] = t(:added, scope: "events.reservations.create", num: @products.size)
      elsif params[:remove].present?
        logger.info "Freeing #{@products.size} products"
        @event.offer(@products, metadata: domain_event_metadata)
        flash[:notice] = t(:removed, scope: "events.reservations.create", num: @products.size)
      elsif params[:lease].present?
        logger.info "Leasing #{@instances.map(&:serial_no).inspect}"
        @event.lease(@instances, metadata: domain_event_metadata)
        flash[:notice] = t(:leased, scope: "events.reservations.create", num: @instances.size)
      elsif params[:lease_all].present?
        logger.info "Leasing all instances"
        @event.lease_all(metadata: domain_event_metadata)
        flash[:notice] = t(:leased_all, scope: "events.reservations.create", num: @event.reservations.size)
      elsif params[:return].present?
        logger.info "Returning #{@instances.map(&:serial_no).inspect}"
        @event.return(@instances, metadata: domain_event_metadata)
        flash[:notice] = t(:returned, scope: "events.reservations.create", num: @instances.size)
      elsif params[:hold].present?
        logger.info "Returning #{@instances.map(&:serial_no).inspect}"
        @event.return(@instances, metadata: domain_event_metadata)
        flash[:notice] = t(:returned, scope: "events.reservations.create", num: @instances.size)

        # Mark all returned instances as held as well
        logger.info "Holding #{@instances.map(&:serial_no).inspect}"
        @instances.each{|instance| instance.hold!(metadata: domain_event_metadata)}
      elsif params[:switch].present?
        logger.info "Switching #{@instances.map(&:serial_no).inspect}"
        @event.switch(@instances, metadata: domain_event_metadata)
        flash[:notice] = t(:switched, scope: "events.reservations.create", num: @instances.size)
      else
        raise "ASSERTION ERROR: One of add and remove were supposed to be filled in, none were?!?"
      end

      @event.save!
    end

    respond_to do |format|
      format.html do
        if params[:back_to_event].present?
          redirect_to event_path(@event)
        elsif params[:back_to_manage].present?
          redirect_to event_reservations_path(@event, manage: 1)
        else
          redirect_to action: :index
        end
      end

      format.js do
        @double_booked_products = Product.double_booked(@event).to_set

        # We must reload products because we worked on the event's products instead
        # This is a limitation of the ActiveRecord implementation
        if params[:products].present?
          @products = current_group.products.includes(reservations: [:event, :instance]).where(slug: params[:products].keys).to_a
          @consumables = []
        end

        if params[:instances].present?
          @instances = current_group.instances.includes(reservations: :product).where(serial_no: params[:instances].keys).to_a
          @products  = @instances.map(&:product).uniq
          @consumables = []
        end

        if params[:consumables].present?
          @consumables = current_group.consumables.where(slug: params[:consumables].keys).to_a
          @products = []
        end

        @reservations = @event.reservations.with_product.page(params[:page])

        # Don't prepare a flash, because we won't need to show it: the UI updates
        # immediately and the end-user can't be surprised. What would be surprising
        # is getting a flash message when they navigate away from the page.
        flash[:notice] = nil
        flash[:alert]  = nil

        render
      end
    end

  rescue Event::DoubleBookingError
    respond_to do |format|
      format.html do
        if params[:back_to_event].present?
          redirect_to event_path(@event)
        elsif params[:back_to_manage].present?
          redirect_to event_reservations_path(@event, manage: 1)
        else
          redirect_to action: :index
        end
      end

      format.js do
        @alert = t("events.reservations.create.double_booking_error_alert")
        render action: :double_booking_error
      end
    end
  end

  private

  def set_event
    @event = current_group.events.includes(reservations: [:product, instance: :reservations]).find_by!(slug: params[:event_id])
  end

  def render_regular
    @filter = params[:filter]

    @categories = Category.by_name.to_a
    @selected_categories = @categories.select{|category| params[category.name] == "1"}.to_set

    service = EntitySearchService.new(
      category_ids:  @selected_categories.map(&:id),
      current_group: current_group,
      page:          params[:page] || 1,
      per_page:      24,
      q:             @filter,
    )

    @entities = service.entities[0, 24]
    @has_next_page = service.has_next_page?

    @reservations = @event.reservations.with_product.all

    options = @selected_categories.map{|key| [key.name, "1"]}.to_h
    options = options.merge(filter: params[:filter])
    @prev_page_path = event_reservations_path(@event, options.merge(page: service.page - 1)) if service.page > 1
    @next_page_path = event_reservations_path(@event, options.merge(page: service.page + 1)) if @has_next_page

    render action: :index
  end

  def render_manage
    @reservations = @event.reservations.with_product.page(params[:page])
    render action: :manage
  end
end
