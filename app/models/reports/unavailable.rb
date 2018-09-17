class Reports::Unavailable
  def initialize(group)
    @group = group
  end

  attr_reader :group

  Row = Struct.new(
    :product_name,
    :product_slug,
    :instance_serial_no,
    :instance_state,
    :instance_slug,
    :last_returned_on
  )

  def rows
    @rows ||=
      Instance.connection.select_rows(rows_sql).map do |row|
        Row.new(*row)
      end
  end

  def quoted_group_id
    Instance.connection.quote(group.id)
  end

  def rows_sql
    <<~EOSQL.gsub(":group_id", quoted_group_id).squish
      SELECT
        products.name                 AS product_name
      , products.slug                 AS product_slug
      , instances.serial_no           AS instance_serial_no
      , instances.state               AS instance_state
      , instances.slug                AS instance_slug
      , max(reservations.returned_on) AS last_returned_on
      FROM instances
           JOIN products     ON products.id              = instances.product_id
      LEFT JOIN reservations ON reservations.instance_id = instances.id
      WHERE instances.state <> 'available'
        AND products.group_id = :group_id
      GROUP BY products.name, products.slug, instances.serial_no, instances.state, instances.slug
      ORDER BY instances.state, last_returned_on
    EOSQL
  end
end
