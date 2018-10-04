class AddAddressToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :address, :text
  end
end
