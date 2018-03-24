class CreateProductCategories < ActiveRecord::Migration[5.2]
  def up
    create_table :product_categories do |t|
      t.belongs_to :product, null: false, foreign_key: true
      t.belongs_to :category, null: false, foreign_key: true

      t.column :created_at, "timestamp with time zone", null: false
      t.column :updated_at, "timestamp with time zone", null: false
    end

    add_index :product_categories, [:product_id, :category_id], unique: true
  end

  def down
    drop_table :product_categories
  end
end
