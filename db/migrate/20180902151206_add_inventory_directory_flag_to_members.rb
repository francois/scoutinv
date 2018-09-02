class AddInventoryDirectoryFlagToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :inventory_director, :boolean, default: false, null: false
  end
end
