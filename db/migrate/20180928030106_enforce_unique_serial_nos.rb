class EnforceUniqueSerialNos < ActiveRecord::Migration[5.2]
  def change
    add_index :instances, :serial_no, unique: true
  end
end
