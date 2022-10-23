module EntityHelper
  def entity_image(entity, height: 250)
    if image = entity.images.first
      if image.blob && image.variable?
        return link_to(image_tag(image.variant(WEB_IMAGE_CONFIG.merge(resize: "x#{height}")), height: height, alt: "", class: "entity-image"), entity, class: "float-center")
      end
    end

    link_to image_tag("https://via.placeholder.com/#{Integer(height)}x#{Integer(height)}?text=%20", alt: "", class: "entity-image"), entity, class: "float-center"
  end
end
