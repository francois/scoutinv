class CreateMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :memberships do |t|
      t.belongs_to :troop, :member, null: false
      t.string :slug, limit: 8, null: false, index: { unique: true }

      t.column :created_at, "timestamp with time zone", null: false
      t.column :updated_at, "timestamp with time zone", null: false
    end

    add_index :memberships, [:troop_id, :member_id], unique: true
  end
end
