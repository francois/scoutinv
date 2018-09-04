module ProductHelper
  def format_serial_no(serial_no)
    t("serial_number", no: serial_no)
  end

  def format_product_location(product, plain: false)
    plain_text = [ product.building, product.aisle, product.shelf, product.unit ].reject(&:blank?).to_sentence(words_connector: " / ", two_words_connector: " / ", last_word_connector: " / ")
    plain ? plain_text : content_tag(:span, plain_text, class: "product-location")
  end
end
