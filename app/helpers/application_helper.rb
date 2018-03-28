module ApplicationHelper
  attr_reader :page_title

  def format_date_range(dates)
    first = dates.first
    last  = dates.last

    if first.year == last.year && first.month == last.month
      first.strftime("%b %-d&mdash;#{last.day}, %Y").html_safe
    elsif first.year == last.year
      first.strftime("%b %-d&mdash;#{last.strftime("%b %-d")}, %Y").html_safe
    else
      [first.strftime("%b %-d, %Y"), " to ", last.strftime("%b %-d, %Y")].join.html_safe
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
end
