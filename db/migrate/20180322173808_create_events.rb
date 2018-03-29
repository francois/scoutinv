class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.belongs_to :group, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.date :start_on, null: false
      t.date :end_on, null: false
      t.string :slug, limit: 8, null: false, index: { unique: true }

      t.column :created_at, "timestamp with time zone", null: false
      t.column :updated_at, "timestamp with time zone", null: false
    end
  end
end
