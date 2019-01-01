module ApplicationHelper
  attr_reader :page_title

  def product_reservation_css_class(event, product)
    overlapping_events = product.reservations.select{|res| res.event_overlaps?(event)}.map(&:event)
    if overlapping_events.include?(event) && overlapping_events.size > product.quantity
      "product-busy-many"
    elsif overlapping_events.include?(event) && overlapping_events.size == 1
      "product-busy-self"
    elsif overlapping_events.size < product.quantity
      "product-available"
    else
      "product-busy-other"
    end
  end

  def on_home_page?
    current_page?(root_path)
  end

  def on_events_page?
    %w(events events/reservations).include?(params[:controller])
  end

  def on_products_page?
    %w(products).include?(params[:controller])
  end

  def on_consumables_page?
    %w(consumables).include?(params[:controller])
  end

  def on_reports_page?
    %w(reports).include?(params[:controller])
  end

  def on_groups_page?
    %w(groups members).include?(params[:controller])
  end
end
