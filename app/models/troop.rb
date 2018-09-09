class Troop < ApplicationRecord
  include HasSlug

  belongs_to :group
  has_many :memberships
  has_many :members, through: :memberships

  def sort_key
    [position, name.downcase]
  end
end
