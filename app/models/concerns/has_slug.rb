module HasSlug
  def self.included(base)
    base.before_create :assign_slug
  end

  def to_key
    [slug]
  end

  def to_param
    slug
  end

  def assign_slug
    self.slug = self.generate_slug if self.slug.blank?
  end

  def generate_slug
    SecureRandom.base58(slug_size).downcase
  end

  def slug_size
    8
  end
end
