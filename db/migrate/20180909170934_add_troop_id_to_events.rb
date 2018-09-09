class AddTroopIdToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :troop_id, :integer
    add_foreign_key :events, :troops, on_update: :cascade, on_delete: :restrict
  end
end
