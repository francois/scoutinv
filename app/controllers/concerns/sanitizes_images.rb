module SanitizesImages
  private

  def sanitize_images(attachables)
    Array.wrap(attachables).compact_blank.map do |attachable|
      sanitize_image(attachable)
    end
  end

  def sanitize_image(attachable)
    sanitized = ImageSanitizer.call(attachable)
    sanitized_images << sanitized
    sanitized
  end

  def close_sanitized_images
    sanitized_images.each { |image| image.fetch(:io).close! }
  end

  def sanitized_images
    @sanitized_images ||= []
  end
end
