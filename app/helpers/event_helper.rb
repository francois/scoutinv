module EventHelper
  def format_date_range(dates)
    first = dates.first
    last  = dates.last

    if first.year == last.year && first.month == last.month && first.day == last.day
      I18n.l(first, format: :same_day)
    elsif first.year == last.year && first.month == last.month
      I18n.l(first, format: :range_same_year_and_month, last_day: last.day)
    elsif first.year == last.year
      I18n.l(first, format: :range_same_year, last_day: I18n.l(last, format: :no_year))
    else
      I18n.l(first, format: :range_other, last_day: I18n.l(last, format: :with_year))
    end
  end
end
