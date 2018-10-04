class ExternalRenterContractPdfPrinter < ContractPdfPrinter
  def render_renter_name(pdf)
    rows = []
    rows << {text: "#{t(:renter)}\n", size: 10, styles: [:italic]}
    rows << {text: "#{event.name}\n", styles: [:bold], size: 14}
    rows << {text: "#{event.address}\n\n"} if event.address.present?
    rows << {text: "#{t(:email)}: #{event.email}\n"}
    rows << {text: "#{t(:phone)}: #{event.phone}\n"}
    rows << {text: "#{t(:event)}: #{event.title}\n"}

    pdf.formatted_text_box rows, at: [0, pdf.cursor], width: 300
  end

  def num_lines_for_renter_name
    rows = [ 5 ]
    rows << event.address.to_s.split("\n").size
    rows << 1 if event.address.present?
    rows.sum
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
