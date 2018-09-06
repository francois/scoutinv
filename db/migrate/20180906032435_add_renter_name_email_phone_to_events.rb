class AddRenterNameEmailPhoneToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :name,  :text
    add_column :events, :email, :text
    add_column :events, :phone, :text
  end
end
