class CreateNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :notes do |t|
      t.belongs_to :parent, null: false, polymorphic: true
      t.belongs_to :author, null: false, foreign_key: {to_table: :users}
      t.text :body, null: false
      t.string :slug, limit: 8, null: false, index: { unique: true }

      t.column :created_at, "timestamp with time zone", null: false
      t.column :updated_at, "timestamp with time zone", null: false
    end
  end
end
