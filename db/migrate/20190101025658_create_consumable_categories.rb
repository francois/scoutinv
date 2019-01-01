class CreateConsumableCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :consumable_categories do |t|
      t.belongs_to :category,   null: false, foreign_key: true
      t.belongs_to :consumable, null: false, foreign_key: true

      t.timestamps null: false
    end
  end
end
