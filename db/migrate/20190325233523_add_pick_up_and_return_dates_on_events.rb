class AddPickUpAndReturnDatesOnEvents < ActiveRecord::Migration[5.2]
  def up
    add_column :events, :pick_up_on, :date
    add_column :events, :return_on, :date

    execute "UPDATE events SET pick_up_on = start_on, return_on = end_on"

    change_column_null :events, :pick_up_on, false
    change_column_null :events, :return_on, false
  end

  def down
    remove_column :events, :pick_up_on
    remove_column :events, :return_on
  end
end
