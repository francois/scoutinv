class ExternalRenterContractPdfPrinter < ContractPdfPrinter
  def render_renter_name(pdf)
    pdf.formatted_text_box [
      {text: "#{t(:renter)}\n", size: 10, styles: [:italic]},
      {text: "#{event.name}\n", styles: [:bold], size: 14},
      {text: "#{t(:email)}: #{event.email}\n#{t(:phone)}: #{event.phone}\n#{t(:event)}: #{event.title}"},
    ],
    at: [0, pdf.cursor],
    width: 300
  end

  def num_lines_for_renter_name
    5
  end

  def render_renter_terms_and_conditions(pdf)
    pdf.start_new_page if pdf.cursor < 200
    pdf.text t(:terms_and_conditions_header), style: :bold, size: 14
    pdf.text t(:terms_and_conditions_for_external_renter, name: event.name, group_name: event.group_name)
    pdf.stroke_horizontal_line   0, 300, at: pdf.cursor - 36
    pdf.stroke_horizontal_line 400, 500, at: pdf.cursor - 36
    pdf.move_down 40
    pdf.text_box event.name, size: 10, style: :italic, at: [0, pdf.cursor]
    pdf.text_box t(:date), size: 10, at: [400, pdf.cursor]
    pdf.move_down 30
  end
end
