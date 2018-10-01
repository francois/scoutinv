class AddUnitPriceOnReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :unit_price, :decimal, default: 0, null: false
  end
end
