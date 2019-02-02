class UseCitextForProductAndConsumableName < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE EXTENSION IF NOT EXISTS \"citext\""
    change_column :products, :name, :citext
    change_column :consumables, :name, :citext
  end

  def down
    change_column :consumables, :name, :string
    change_column :products, :name, :string
    execute "DROP EXTENSION IF EXISTS \"citext\""
  end
end
