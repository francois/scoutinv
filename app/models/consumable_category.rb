class ConsumableCategory < ApplicationRecord
  belongs_to :category
  belongs_to :consumable

  validates :consumable, :category, presence: true
end
