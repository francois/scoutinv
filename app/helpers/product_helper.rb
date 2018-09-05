module ProductHelper
  def format_serial_no(serial_no)
    t("serial_number", no: serial_no)
  end

  def format_product_location(product, plain: false)
    plain_text = [ product.building, product.aisle, product.shelf, product.unit ].reject(&:blank?).to_sentence(words_connector: " / ", two_words_connector: " / ", last_word_connector: " / ")
    plain ? plain_text : content_tag(:span, plain_text, class: "product-location")
  end

  def product_image(product, height: 250)
    if product.images.first&.blob
      link_to(image_tag(product.images.first.variant(WEB_IMAGE_CONFIG.merge(resize: "x#{height}")), height: height, alt: "", class: "product-image"), product, class: "float-center")
    else
      link_to(image_tag("https://via.placeholder.com/#{height}x#{height}?text=%20", alt: "", class: "product-image"), product, class: "float-center")
    end
  end
end
