class AddQuantityToProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :quantity, :integer, default: 1
    execute <<-EOSQL.squish
      UPDATE products
      SET quantity = product_quantities.quantity
      FROM (
        SELECT product_id, count(*) AS quantity
        FROM instances
        GROUP BY product_id) AS product_quantities
      WHERE product_quantities.product_id = products.id
    EOSQL

    change_column_null :products, :quantity, false
  end

  def down
    remove_column :products, :quantity
  end
end
