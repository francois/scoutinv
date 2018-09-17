require "prawn"

class ContractPdfPrinter
  include EventHelper
  include ProductHelper
  include ActionView::Helpers::NumberHelper

  def initialize(event, author:, printed_on: Date.today)
    @event      = event
    @author     = author
    @printed_on = I18n.l(printed_on, format: :iso8601)
  end

  attr_reader :event, :author, :printed_on

  def filename
    "#{printed_on}-#{slugify(event.title)}-#{event.slug}.pdf"
  end

  def print
    info = {
      Title: event.title,
      Author: "#{author.name} <#{author.email}>",
      CreationDate: printed_on,
    }

    pdf = Prawn::Document.new(page_size: "LETTER", page_layout: :landscape, info: info)
    pdf.font "Helvetica"
    pdf.font_size 12

    render_page_header(pdf)
    render_head(pdf)
    render_body(pdf)
    render_tail(pdf)

    # must be called last, to number existing pages
    render_page_numbers(pdf)
    pdf.render
  end

  def render_page_header(pdf)
    pdf.repeat(:all) do
      pdf.draw_text event.title, at: [                    0, -6], size: 8, width: pdf.bounds.width
      pdf.draw_text printed_on,  at: [pdf.bounds.width - 45, -6], size: 8, width: 45
    end
  end

  def render_head(pdf)
    pdf.text t(:title), size: 24, style: :bold

    pdf.move_down 10

    render_renter_name(pdf)

    pdf.formatted_text_box [
      {text: "#{t(:lender)}\n", size: 10, styles: [:italic]},
      {text: "#{event.group_name}\n", styles: [:bold], size: 14},
      {text: event.group.members.select(&:inventory_director?).sort_by(&:sort_key).map{|member| "#{member.name} #{member.email}"}.join("\n")},
    ],
    at: [400, pdf.cursor],
    width: 300

    # That 6 at the end is extra padding to make things look better
    pdf.move_down 10 + 14 + 12 * [num_lines_for_renter_name, event.group.members.select(&:inventory_director?).size].max + 6

    top_pos = pdf.cursor
    pdf.fill_color "EEEEEE"
    pdf.fill_rectangle [0, top_pos], pdf.bounds.width, 24
    pdf.fill_color "000000"
    pdf.formatted_text_box [{text: "#{t(:lease_start_on_title)}: "}, {text: I18n.l(event.start_on,   format: :with_year), styles: [:bold]}], at: [  0, top_pos - 6], size: 12, width: 400
    pdf.formatted_text_box [{text: "#{t(:lease_end_on_title)}: "},   {text: I18n.l(event.end_on + 1, format: :with_year), styles: [:bold]}], at: [400, top_pos - 6], size: 12

    pdf.move_down 3 * 12 # one line for the text above, one line of padding (1/2 top/bottom), an extra blank line for readability purposes

    if event.description.present?
      pdf.text t(:instructions_title, group_name: event.group_name), style: :bold
      pdf.text event.description, size: 10
      pdf.move_down 12
    end
  end

  def render_body(pdf)
    data = [
      ["Produit", "Quantité", "Prix Unitaire", "Sous-total"],
    ]

    event.reservations.group_by(&:product).sort_by{|product, _| product.sort_key_for_pickup}.inject(data) do |memo, (product, reservations)|
      text = ""
      text << "<b>#{product.name}</b>"
      text << " "
      text << "<font size='10'><i>"
      text << format_product_location(product, plain: true)
      text << "</i></font>"
      text << "\n"
      text << "<font size='10'>"
      text << reservations.map(&:serial_no).map{|serial_no| format_serial_no(serial_no)}.join("  ") # 2 NON-BREAKING SPACEs
      text << "</font>"

      memo << [text, reservations.size, t(:not_available), t(:not_available)]
    end

    data << [nil, nil, t(:total_header), number_to_currency(0)]

    pdf.table(data, cell_style: {inline_format: true}, header: true, width: pdf.bounds.width) do
      cells.borders = []

      row(0).borders       = [:bottom]
      row(0).border_width  = 0.5
      row(0).font_style    = :bold
      row(-2).border_width = 0.5
      row(-2..-1).borders  = [:bottom]
      row(-1).border_width = 1
      row(-1).font_style   = :bold

      column(1..-1).width = 80

      column(0).align    = :left
      column(1).align    = :center
      column(2..3).align = :right
    end
  end

  def render_tail(pdf)
    render_event_notes(pdf) if event.notes.reject(&:new_record?).any?

    pdf.start_new_page if pdf.cursor < 300
    pdf.move_down 24
    pdf.fill_color "EEEEEE"
    pdf.fill_rectangle [0, pdf.cursor], pdf.bounds.width, 80
    pdf.fill_color "000000"
    pdf.move_down 7
    pdf.text t(:quality_control_at_lease_start_header), style: :bold, size: 14
    pdf.stroke_horizontal_line   0, 300, at: pdf.cursor - 36
    pdf.stroke_horizontal_line 400, 500, at: pdf.cursor - 36
    pdf.move_down 40
    pdf.text_box t(:inventory_director_at_group, group_name: event.group_name), size: 10, style: :italic, at: [0, pdf.cursor]
    pdf.text_box t(:date), size: 10, at: [400, pdf.cursor]
    pdf.move_down 30

    render_renter_terms_and_conditions(pdf)

    pdf.start_new_page if pdf.cursor < 100
    pdf.fill_color "EEEEEE"
    pdf.fill_rectangle [0, pdf.cursor], pdf.bounds.width, 80
    pdf.fill_color "000000"
    pdf.move_down 7
    pdf.text t(:quality_control_at_lease_end_header), style: :bold, size: 14
    pdf.stroke_horizontal_line   0, 300, at: pdf.cursor - 36
    pdf.stroke_horizontal_line 400, 500, at: pdf.cursor - 36
    pdf.move_down 40
    pdf.text_box t(:inventory_director_at_group, group_name: event.group_name), size: 10, style: :italic, at: [0, pdf.cursor]
    pdf.text_box t(:date), size: 10, at: [400, pdf.cursor]
  end

  def render_event_notes(pdf)
    pdf.move_down 24
    pdf.text t(:notes_header), size: 12, style: :bold
    pdf.move_down 4
    event.notes.reject(&:new_record?).sort_by(&:created_at).each do |note|
      pdf.text note.body
      pdf.formatted_text [{text: note.author_name, size: 8, styles: [:bold]}, {text: " ", size: 8}, {text: I18n.l(note.created_at, format: :with_year), size: 8, styles: [:italic]}]
      pdf.move_down 4
      pdf.stroke_horizontal_rule
      pdf.move_down 4
    end
  end

  def render_page_numbers(pdf)
    options = {
      align: :center,
      at: [(pdf.bounds.width / 2) - 50, 0],
      size: 8,
      start_count: 1,
      width: 100,
    }

    pdf.number_pages t(:page_numbering), options
  end

  def slugify(string)
    raise ArgumentError, "string must not be nil: #{string.inspect}" if string.nil?

    string
      .downcase
      .gsub(/[^a-z0-9âàäéèêëïüöô]/, "-")
      .gsub(/-+/, "-")
  end

  def t(*args)
    options = args.extract_options!
    options.reverse_merge!(scope: "contract")
    I18n.t(*args, options)
  end
end
