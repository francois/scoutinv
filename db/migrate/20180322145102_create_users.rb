class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.belongs_to :group, foreign_key: true, null: false
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :encrypted_password, null: false
      t.string :slug, limit: 8, null: false, index: { unique: true }

      t.column :created_at, "timestamp with time zone", null: false
      t.column :updated_at, "timestamp with time zone", null: false
    end
  end
end
