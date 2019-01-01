class CreateConsumables < ActiveRecord::Migration[5.2]
  def change
    create_table :consumables do |t|
      t.belongs_to :group, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :slug, null: false
      t.text :building
      t.text :aisle
      t.text :shelf
      t.text :unit
      t.integer :base_quantity_value, null: false, default: 1
      t.text :base_quantity_si_prefix, null: false, default: SI::BASE
      t.text :base_quantity_unit, null: false, default: "unit"
      t.numeric :internal_unit_price, null: false, default: 0
      t.numeric :external_unit_price, null: false, default: 0

      t.timestamps null: false
    end
  end
end
