class ShrinkImageJob < ApplicationJob
  def perform(product, image)
    logger.info "Shrinking #{product.slug}:#{image.id}"

    Product.transaction do
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
