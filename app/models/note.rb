class Note < ApplicationRecord
  include HasSlug

  belongs_to :parent, polymorphic: true
  belongs_to :author, class_name: "User"

  validates :author, :parent, :body, presence: true
  validates :body, length: { minimum: 2 }

  delegate :name, prefix: :author, to: :author
end
