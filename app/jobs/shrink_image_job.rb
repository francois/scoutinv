class ShrinkImageJob < ApplicationJob
  def run(product_or_consumable_id, image_id)
    Product.transaction do
      product = Product.where(id: product_or_consumable_id).first || Consumable.find(product_or_consumable_id)
      image = product.images.find(image_id)
      logger.info "Shrinking #{product.slug}:#{image.id}"

      logger.info "Creating highest quality version"
      image.variant(WEB_IMAGE_CONFIG).processed

      logger.info "Creating smallest thumbnail"
      image.variant(WEB_IMAGE_CONFIG.merge(resize: "x100")).processed

      logger.info "Creating medium thumbnail"
      image.variant(WEB_IMAGE_CONFIG.merge(resize: "x250")).processed

      logger.info "Creating largest thumbnail"
      image.variant(WEB_IMAGE_CONFIG.merge(resize: "300x225")).processed
    end
  end
end
