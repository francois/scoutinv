class AddUnitPricesToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :internal_unit_price, :decimal, default: 0, null: false
    add_column :products, :external_unit_price, :decimal, default: 0, null: false
  end
end
