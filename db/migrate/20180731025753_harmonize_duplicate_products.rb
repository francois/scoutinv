class HarmonizeDuplicateProducts < ActiveRecord::Migration[5.2]
  def up
    # Make sure the sequence is updated w.r.t. inserted rows
    execute "SELECT setval('instances_id_seq', max(id)) FROM instances"

    products = select_rows(<<-EOSQL.squish)
      SELECT name AS "name", array_agg(DISTINCT id ORDER BY id) AS "ids"
      FROM "products"
      GROUP BY "name"
      HAVING count(*) > 1
    EOSQL

    products.each do |(name, ids)|
      ids = ids.gsub(/[{}]/, "").split(",").map(&:to_i)
      execute "DELETE FROM products WHERE id IN (#{ids[1..-1].join(", ")})"
      rows = ids[1..-1].each_with_index.map do |_, index|
        [ids.first, 2 + index, SecureRandom.base58(8).downcase, Time.current, Time.current].map{|value| quote(value)}.join(", ").insert(0, "(").insert(-1, ")")
      end
      execute "INSERT INTO instances(product_id, serial_no, slug, created_at, updated_at) VALUES #{rows.join(", ")}"
    end
  end
end
