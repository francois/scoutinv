class AddMaxQuantityOnCategories < ActiveRecord::Migration[5.2]
  def up
    add_column :categories, :max_quantity, :integer
    execute "UPDATE categories SET max_quantity = 99"
    change_column_null :categories, :max_quantity, false
  end

  def down
    remove_column :categories, :max_quantity
  end
end
