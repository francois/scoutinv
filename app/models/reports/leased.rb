class Reports::Leased
  def initialize(group)
    @group = group
  end

  attr_reader :group

  Row = Struct.new(
    :product_name,
    :product_slug,
    :instance_serial_no,
    :reservation_leased_on,
    :instance_state,
    :instance_slug,
    :event_title,
    :event_slug,
    :event_end_on
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
        products.name          AS product_name
      , products.slug          AS product_slug
      , instances.serial_no    AS instance_serial_no
      , reservations.leased_on AS reservation_leased_on
      , instances.state        AS instance_state
      , instances.slug         AS instance_slug
      , events.title           AS event_title
      , events.slug            AS event_slug
      , events.end_on          AS event_end_on
      FROM reservations
      JOIN instances ON instances.id = reservations.instance_id
      JOIN products  ON products.id  = instances.product_id
      JOIN events    ON events.id    = reservations.event_id
      WHERE events.group_id = :group_id
        AND leased_on   IS NOT NULL
        AND returned_on IS     NULL
      ORDER BY leased_on
    EOSQL
  end
end
