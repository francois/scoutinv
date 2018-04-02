class Group < ApplicationRecord
  include HasSlug

  has_many :products, inverse_of: :group
  has_many :events,   inverse_of: :group
  has_many :members,  inverse_of: :group

  validates :name, presence: true, length: { minimum: 2 }
end
