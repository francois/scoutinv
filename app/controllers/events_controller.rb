class EventsController < ApplicationController
  before_action :set_event, except: [:index, :new, :create]

  def index
    @page_title = I18n.t("events.index.page_title")

    @after = params[:after].present? ? params[:after].to_date : 10.days.ago

    @events = current_group.events.includes(:troop).by_date
    @events = @events.after(@after)
    @events = @events.all
  end

  def show
    @page_title = @event.title
    @note = @event.notes.build

    @double_booked_products = Product.double_booked(@event).to_set

    service = EntitySearchService.new(
      current_group: current_group,
      event_id: @event.id,
    )
    @entities = service.entities

    @used_categories = @entities.map(&:categories).flatten.uniq.sort_by(&:name)

    respond_to do |format|
      format.html { render action: :show }
      format.pdf do
        generator =
          if @event.internal?
            TroopContractPdfPrinter.new(@event, author: current_member)
          else
            ExternalRenterContractPdfPrinter.new(@event, author: current_member)
          end
        send_data generator.print, filename: generator.filename, type: :pdf, disposition: :inline
      end
    end
  end

  def new
    @page_title = I18n.t("events.new.page_title")
    @event = Event.new
    @event.troop = current_member.troops.first if current_member.troops.size == 1
  end

  def edit
    @page_title = I18n.t("events.edit.page_title", event: @event.title)
  end

  def create
    current_group.transaction do
      @event = current_group.register_new_event(event_params, metadata: domain_event_metadata)

      if current_group.save
        redirect_to @event, notice: t(".event_successfully_created")
      else
        @page_title = "New Event"
        render :new
      end
    end
  end

  def update
    current_group.transaction do
      if @event.change_information(event_params, metadata: domain_event_metadata)
        redirect_to @event, notice: t(".event_successfully_updated")
      else
        @page_title = "Edit #{@event.title}"
        render :edit
      end
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: t(".event_successfully_destroyed")
  end

  def finalize
    @event.finalize!
    flash[:notice] = I18n.t("events.notify.notified")
    redirect_to @event
  end

  def ready
    @event.ready!
    flash[:notice] = I18n.t("events.notify.ready")
    redirect_to @event
  end

  def audit
    @event.audit!
    flash[:notice] = I18n.t("events.notify.audited")
    redirect_to @event
  end

  def redraw
    @event.redraw!
    flash[:notice] = I18n.t("events.notify.redrawn")
    redirect_to @event
  end

  private

  def set_event
    @event = current_group.events.includes(consumable_transactions: [:consumable, :categories], reservations: [:product, :instance]).find_by!(slug: params[:id])
  end

  def event_params
    params.require(:event).permit(
      :address,
      :description,
      :email,
      :end_on,
      :name,
      :phone,
      :pick_up_on,
      :return_on,
      :start_on,
      :title,
      :troop_id,
    )
  end
end
