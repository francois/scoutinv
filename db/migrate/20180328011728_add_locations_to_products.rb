class AddLocationsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :aisle, :text
    add_column :products, :shelf, :text
    add_column :products, :unit, :text
  end
end
