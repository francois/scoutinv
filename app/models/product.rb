class Product < ApplicationRecord
  include HasSlug

  belongs_to :group
  has_many :reservations

  scope :by_name, ->{ order(Arel.sql("LOWER(name), id")) }
  scope :search, ->(string){ where(Arel.sql("POSITION(? IN name || ' ' || COALESCE(description, '')) > 0", string)) }
  scope :with_reservations, ->{ includes(reservations: :event) }

  validates :name, presence: true, length: { minimum: 2 }

  # Returns a string to be used for ordering a list of products consistently
  #
  # @return [String] The key to use to order this item consistently
  def sort_key
    [name.downcase, id].map(&:to_s).join(":")
  end
end
