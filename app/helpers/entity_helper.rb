module EntityHelper
  def entity_image(entity, height: 250)
    if entity.images.first&.blob
      link_to image_tag(entity.images.first.variant(WEB_IMAGE_CONFIG.merge(resize: "x#{height}")), height: height, alt: "", class: "entity-image"), entity, class: "float-center"
    else
      link_to image_tag("https://via.placeholder.com/#{Integer(height)}x#{Integer(height)}?text=%20", alt: "", class: "entity-image"), entity, class: "float-center"
    end
  end
end
