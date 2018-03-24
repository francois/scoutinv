class Category < ApplicationRecord
  include HasSlug

  has_many :product_categories
  has_many :products, through: :product_categories

  scope :by_name, ->{ order(Arel.sql("LOWER(name)")) }

  validates :name, presence: true, length: { minimum: 2 }
end
