class DropPasswordFromMembers < ActiveRecord::Migration[5.2]
  def up
    remove_column :members, :encrypted_password
  end
end
