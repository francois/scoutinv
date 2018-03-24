class Events::ReservationsController < ApplicationController
  before_action :set_event

  def index
    @filter = params[:filter]

    @categories = Category.by_name.to_a
    @selected_category = @categories.detect{|category| category.slug == params[:category]}

    @products     = current_group.products.with_categories.with_reservations.by_name
    @products     = @products.search(@filter) if @filter.present?
    @products     = @products.in_category(@selected_category) if @selected_category
    @products     = @products.all
    @reservations = @event.reservations.with_product.all
  end

  def create
    products = current_group.products.where(slug: params[:products].keys).to_a

    if params[:add].blank? && params[:remove].blank?
      # NOP
    elsif params[:add].present? && params[:present].present?
      # NOP
    elsif params[:add].present?
      @event.add(products)
    elsif params[:remove].present?
      @event.remove(products)
    else
      raise "ASSERTION ERROR: One of add and remove were supposed to be filled in, none were?!?"
    end

    @event.save!
    redirect_to action: :index
  end

  private

  def set_event
    @event = current_group.events.find_by!(slug: params[:id])
  end
end
