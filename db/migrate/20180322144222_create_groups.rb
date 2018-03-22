class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.string :slug, limit: 8, null: false, index: { unique: true }

      t.column :created_at, "timestamp with time zone", null: false
      t.column :updated_at, "timestamp with time zone", null: false
    end
  end
end
