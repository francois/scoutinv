module EntityHelper
  def forest_product_card_image(entity, path: entity, width: 640, height: 480)
    content =
      if (image = entity.images.first) && image.blob && image.variable?
        image_tag(
          image.variant(WEB_IMAGE_CONFIG.merge(resize_to_limit: [ width, height ])),
          alt: "",
          class: "forest-product-card__image",
          decoding: "async",
          height: height,
          loading: "lazy",
          width: width,
        )
      else
        content_tag(:span, class: "forest-product-card__image-placeholder") do
          safe_join([
            content_tag(:span, entity.name.first.to_s.upcase, class: "forest-product-card__image-initial", aria: { hidden: true }),
            content_tag(:span, t("#{entity.model_name.i18n_key.to_s.pluralize}.card.no_photo")),
          ])
        end
      end

    link_to(
      content,
      path,
      class: "forest-product-card__image-link",
      aria: { label: t("#{entity.model_name.i18n_key.to_s.pluralize}.card.view_#{entity.model_name.i18n_key}", entity.model_name.i18n_key => entity.name) },
    )
  end

  def product_reservation_card_data(event, product)
    selected_reservations = event.reservations_of(product)
    available_instance_ids = product.instances.select(&:available?).map(&:id).to_set

    overlapping_reservations = product.reservations.select do |reservation|
      reservation.event_overlaps?(event)
    end
    occupied_instance_ids = overlapping_reservations.map(&:instance_id).to_set

    all_reservations_elsewhere = overlapping_reservations.reject do |reservation|
      reservation.event_id == event.id
    end
    reservations_elsewhere = all_reservations_elsewhere.select do |reservation|
      available_instance_ids.include?(reservation.instance_id)
    end

    conflicts = selected_reservations.flat_map do |selected_reservation|
      all_reservations_elsewhere.select do |other_reservation|
        other_reservation.instance_id == selected_reservation.instance_id
      end.map do |other_reservation|
        {
          event: other_reservation.event,
          serial_no: selected_reservation.serial_no,
        }
      end
    end.uniq{|conflict| [ conflict[:event].id, conflict[:serial_no] ]}

    other_bookings = reservations_elsewhere.group_by(&:event).map do |other_event, reservations|
      {
        event: other_event,
        quantity: reservations.map(&:instance_id).uniq.size,
      }
    end.sort_by{|booking| [ booking[:event].pick_up_on, booking[:event].title ]}

    {
      conflicts: conflicts,
      other_bookings: other_bookings,
      reserved_elsewhere_quantity: reservations_elsewhere.map(&:instance_id).uniq.size,
      remaining_quantity: (available_instance_ids - occupied_instance_ids).size,
      selected_quantity: selected_reservations.size,
      total_quantity: product.instances.size,
      unavailable_quantity: product.instances.size - available_instance_ids.size,
    }
  end

  def entity_image(entity, height: 250)
    if image = entity.images.first
      if image.blob && image.variable?
        return link_to(image_tag(image.variant(WEB_IMAGE_CONFIG.merge(resize_to_limit: [ nil, height ])), height: height, alt: "", class: "entity-image"), entity, class: "float-center")
      end
    end

    link_to image_tag("https://via.placeholder.com/#{Integer(height)}x#{Integer(height)}?text=%20", alt: "", class: "entity-image"), entity, class: "float-center"
  end
end
