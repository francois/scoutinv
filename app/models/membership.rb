class Membership < ApplicationRecord
  include HasSlug

  belongs_to :troop
  belongs_to :member
end
