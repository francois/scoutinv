class CreateConsumableTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :consumable_transactions do |t|
      t.belongs_to :consumable, foreign_key: true
      t.string :reason
      t.belongs_to :event, foreign_key: true
      t.float :quantity_value, null: false
      t.string :quantity_si_prefix, null: false
      t.string :quantity_unit, null: false

      t.timestamps null: false
    end
  end
end
