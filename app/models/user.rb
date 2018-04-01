class User < ApplicationRecord
  include HasSlug

  belongs_to :group
  has_many :sessions, class_name: "UserSession", dependent: :delete_all

  attr_accessor :password, :password_confirmation
  before_save :assign_password

  validates :email,    presence: true, length: { minimum: 4 }, format: /\A.+@.+[.]\w{2,}\z/
  validates :group,    presence: true
  validates :name,     presence: true, length: { minimum: 2 }
  validates :password, presence: true, length: { minimum: 6, maximum: 250 }, confirmation: true, if: :new_record?

  def create_session_token!
    delete_pending_sessions
    session = sessions.create!
    session.token
  end

  def delete_pending_sessions
    sessions.delete_all
  end

  def self.authenticate!(slug:, token:)
    user_session = UserSession.
      includes(:user).
      where(users: { slug: slug }).
      find_by!(token: token)

    user_session.user.tap(&:delete_pending_sessions)
  end

  def sort_key
    name.to_s.downcase
  end

  private

  def assign_password
    return if password.blank?
    self.encrypted_password = BCrypt::Password.create(self.password)
  end
end
