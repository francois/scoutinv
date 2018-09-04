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

  def on_groups_page?
    %w(groups members).include?(params[:controller])
  end

  def product_image(product, height: 250)
    if product.images.first&.blob
      link_to(image_tag(product.images.first.variant(resize: "x#{height}", strip: true, quality: 75), height: height, alt: "", class: "product-image"), product, class: "float-center")
    else
      link_to(image_tag("https://via.placeholder.com/#{height}x#{height}?text=%20", alt: "", class: "product-image"), product, class: "float-center")
    end
  end
end
