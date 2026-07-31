class DomainEvent < ApplicationRecord
  belongs_to :model, polymorphic: true
end
