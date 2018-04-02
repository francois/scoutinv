class Member < ApplicationRecord
  include HasSlug

  belongs_to :group
  has_many :sessions, class_name: "MemberSession", dependent: :delete_all

  validates :email,    presence: true, length: { minimum: 4 }, format: /\A.+@.+[.]\w{2,}\z/
  validates :group,    presence: true
  validates :name,     presence: true, length: { minimum: 2 }

  def create_session_token!
    delete_pending_sessions
    session = sessions.create!
    session.token
  end

  def delete_pending_sessions
    sessions.delete_all
  end

  def self.authenticate!(slug:, token:)
    member_session = MemberSession.
      includes(:member).
      where(members: { slug: slug }).
      find_by!(token: token)

    member_session.member.tap(&:delete_pending_sessions)
  end

  def sort_key
    name.to_s.downcase
  end
end
