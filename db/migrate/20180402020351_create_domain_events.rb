class CreateDomainEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :domain_events do |t|
      t.belongs_to :model, null: false, polymorphic: true
      t.string :type, null: false
      t.jsonb :data, :metadata, null: false

      t.column :created_at, "timestamp with time zone", null: false
      t.column :updated_at, "timestamp with time zone", null: false
    end
  end
end
