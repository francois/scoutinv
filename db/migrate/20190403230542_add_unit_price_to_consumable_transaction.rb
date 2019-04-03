class AddUnitPriceToConsumableTransaction < ActiveRecord::Migration[5.2]
  def up
    add_column :consumable_transactions, :unit_price, :decimal
    execute "UPDATE consumable_transactions SET unit_price = 0"
    change_column_null :consumable_transactions, :unit_price, false
  end

  def down
    remove_column :consumable_transactions, :unit_price
  end
end
