class Member < ApplicationRecord
  include HasSlug

  belongs_to :group
  has_many :sessions,      dependent: :delete_all, autosave: true,            class_name: "MemberSession"
  has_many :domain_events, dependent: :delete_all, autosave: true, as: :model

  validates :email,    presence: true, length: { minimum: 4 }, format: /\A.+@.+[.]\w{2,}\z/
  validates :group,    presence: true
  validates :name,     presence: true, length: { minimum: 2 }

  def change_member_identification(attributes, metadata: {})
    transaction do
      self.attributes = attributes
      domain_events << MemberIdentificationChanged.new(
        data: {
          email: email_changed? ? attributes.fetch(:email) : nil,
          name:  name_changed?  ? attributes.fetch(:name)  : nil,
          user_slug: slug,
        }.compact,
        metadata: metadata,
      )

      save
    end
  end

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
