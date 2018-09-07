class AddStateToInstances < ActiveRecord::Migration[5.2]
  def change
    add_column :instances, :state, :text, null: false, default: "available"
  end
end
