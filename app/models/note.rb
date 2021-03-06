class Note < ApplicationRecord
  include HasSlug

  belongs_to :parent, polymorphic: true
  belongs_to :author, class_name: "Member"

  validates :author, :parent, :body, presence: true
  validates :body, length: { minimum: 2 }

  delegate :name, :slug, prefix: :author, to: :author
end
