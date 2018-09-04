class AddBuildingToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :building, :text
  end
end
