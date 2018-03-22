class Product < ApplicationRecord
  include HasSlug

  belongs_to :group

  validates :name, presence: true, length: { minimum: 2 }
end
