class User < ApplicationRecord
  include HasSlug

  belongs_to :group

  attr_accessor :password, :password_confirmation
  before_save :assign_password

  validates :email,    presence: true, length: { minimum: 4 }, format: /\A.+@.+[.]\w{2,}\z/
  validates :group,    presence: true
  validates :name,     presence: true, length: { minimum: 2 }
  validates :password, presence: true, length: { minimum: 6, maximum: 250 }, confirmation: true, if: :new_record?

  private

  def assign_password
    return if password.blank?
    self.encrypted_password = BCrypt::Password.create(self.password)
  end
end
