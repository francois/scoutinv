class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.belongs_to :group, foreign_key: true, null: false
      t.string :name, null: false
      t.text :description
      t.string :slug, limit: 8, null: false, index: { unique: true }

      t.column :created_at, "timestamp with time zone", null: false
      t.column :updated_at, "timestamp with time zone", null: false
    end
  end
end
