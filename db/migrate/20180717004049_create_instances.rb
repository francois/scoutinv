class CreateInstances < ActiveRecord::Migration[5.2]
  def up
    create_table :instances do |t|
      t.belongs_to :product, null: false
      t.string :serial_no, null: false
      t.string :slug, limit: 8, null: false, index: { unique: true }

      t.column :created_at, "timestamp with time zone", null: false
      t.column :updated_at, "timestamp with time zone", null: false
    end

    execute "CREATE EXTENSION pgcrypto"
    execute <<-EOSQL.squish
      INSERT INTO instances(id, product_id, serial_no, slug, created_at, updated_at)
      SELECT products.id, products.id, left(lower(encode(gen_random_bytes(4), 'base64')), 3), lower(encode(gen_random_bytes(6), 'base64')), products.created_at, products.updated_at
      FROM products
    EOSQL
    execute "DROP EXTENSION pgcrypto"

    ids = select_values "SELECT id FROM instances"
    ids.each do |id|
      serial_no = SecureRandom.alphanumeric(3).upcase
      execute "UPDATE instances SET serial_no = #{quote(serial_no)} WHERE id = #{quote(id)}"
    end

    values = select_rows "SELECT id, serial_no FROM instances WHERE serial_no ~* '[+/]'"
    raise "Generated serial numbers contain invalid URL characters: #{values.inspect}" if values.any?

    add_foreign_key :instances, :products, on_update: :cascade, on_delete: :cascade

    remove_foreign_key :reservations, :products
    rename_column :reservations, :product_id, :instance_id
    add_foreign_key :reservations, :instances, on_update: :cascade, on_delete: :cascade

    add_index :instances, [:product_id, :serial_no], unique: true
  end
end
