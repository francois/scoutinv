class AddLeasedOnToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :leased_on, :date
  end
end
