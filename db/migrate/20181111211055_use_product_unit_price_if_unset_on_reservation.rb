class UseProductUnitPriceIfUnsetOnReservation < ActiveRecord::Migration[5.2]
  def up
    change_column_null :reservations, :unit_price, true
    execute "UPDATE reservations SET unit_price = NULL"
  end
end
