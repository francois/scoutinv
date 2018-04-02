class RenameUsersToMembers < ActiveRecord::Migration[5.2]
  def change
    rename_table :users, :members
    rename_table :user_sessions, :member_sessions
    rename_column :member_sessions, :user_id, :member_id
  end
end
