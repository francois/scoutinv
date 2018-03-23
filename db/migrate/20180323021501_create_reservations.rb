class CreateReservations < ActiveRecord::Migration[5.2]
  def up
    create_table :reservations do |t|
      t.belongs_to :product, null: false, foreign_key: true
      t.belongs_to :event, null: false, foreign_key: true
      t.date :returned_on
      t.string :slug, limit: 8, null: false, index: { unique: true }

      t.column :created_at, "timestamp with time zone", null: false
      t.column :updated_at, "timestamp with time zone", null: false
    end

    add_index :reservations, [:product_id, :event_id], unique: true
  end

  def down
    drop_table :reservations
  end
end
