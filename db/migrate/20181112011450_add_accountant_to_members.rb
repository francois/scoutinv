class AddAccountantToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :accountant, :boolean, null: false, default: false
  end
end
