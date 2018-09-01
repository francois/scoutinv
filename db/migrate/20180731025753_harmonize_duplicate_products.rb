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
      rows = ids[1..-1].map do |_|
        [ids.first, SecureRandom.alphanumeric(3).upcase, SecureRandom.alphanumeric(8).downcase, Time.current, Time.current].map{|value| quote(value)}.join(", ").insert(0, "(").insert(-1, ")")
      end
      execute "INSERT INTO instances(product_id, serial_no, slug, created_at, updated_at) VALUES #{rows.join(", ")}"
    end

    values = select_rows "SELECT id, serial_no FROM instances WHERE serial_no ~* '[+/]'"
    raise "Generated serial numbers contain invalid URL characters: #{values.inspect}" if values.any?
  end
end
