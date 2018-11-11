class AddStatusToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :state, :text, default: "draft", null: false
  end
end
