module ApplicationHelper
  attr_reader :page_title

  def format_date_range(dates)
    first = dates.first
    last  = dates.last

    if first.year == last.year && first.month == last.month && first.day == last.day
      l(first, format: :same_day)
    elsif first.year == last.year && first.month == last.month
      l(first, format: :range_same_year_and_month, last_day: last.day)
    elsif first.year == last.year
      l(first, format: :range_same_year, last_day: l(last, format: :no_year))
    else
      l(first, format: :range_other, last_day: l(last, format: :with_year))
    end
  end

  def product_reservation_css_class(event, product)
    overlapping_events = product.reservations.select{|res| res.dates_overlap?(event)}.map(&:event)
    if overlapping_events.include?(event) && overlapping_events.size > 1
      "product-busy-many"
    elsif overlapping_events.include?(event) && overlapping_events.size == 1
      "product-busy-self"
    elsif overlapping_events.any?
      "product-busy-other"
    else
      "product-available"
    end
  end

  def format_product_location(product)
    content_tag :span, class: "product-location" do
      [ product.aisle, product.shelf, product.unit ].reject(&:blank?).to_sentence(words_connector: " / ", two_words_connector: " / ", last_word_connector: " / ")
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
      link_to(image_tag(product.images.first.variant(resize: "x#{height}"), height: height, alt: "", class: "product-image"), product)
    else
      link_to(image_tag("https://via.placeholder.com/#{height}x#{height}?text=%20", alt: "", class: "product-image"), product)
    end
  end
end
