class MemberSession < ApplicationRecord
  belongs_to :member

  before_validation :set_token

  validates :member, :token, presence: true, length: { minimum: 2 }, uniqueness: true

  private

  def set_token
    self.token = SecureRandom.base58(64)
  end
end
