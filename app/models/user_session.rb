class UserSession < ApplicationRecord
  belongs_to :user

  before_validation :set_token

  validates :user, :token, presence: true, length: { minimum: 2 }, uniqueness: true

  private

  def set_token
    self.token = SecureRandom.base58(64)
  end
end
