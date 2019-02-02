# frozen_string_literal

class EntitySearchService
  def initialize(current_group:, q: nil, page: 1, category_ids: nil, per_page: 24)
    @category_ids  = Array(category_ids)
    @current_group = current_group
    @page          = Integer(page)
    @per_page      = Integer(per_page)
    @q             = q.blank? ? "" : q.to_s

    @category_ids = Category.ids if @category_ids.empty?
  end

  attr_reader :current_group, :category_ids, :page, :per_page, :q

  def has_next_page?
    @entities ||= load_entities
    @entities.size > per_page
  end

  def entities
    @entities ||= load_entities
    @entities[0, per_page]
  end

  private

  def load_entities
    conn = ApplicationRecord.connection
    entity_ids = conn.select_rows(load_entities_sql, "Search Entities")
    entities   = entity_ids.group_by(&:first).map{|key, vals| [key, vals.map(&:second)]}.to_h

    # Normalize, to ensure the keys always exist
    entities["Product"]    = [] unless entities.include?("Product")
    entities["Consumable"] = [] unless entities.include?("Consumable")

    # Now, find the actual values
    products    = current_group.products.with_attached_images.with_categories.with_reservations.find(entities["Product"])
    consumables = current_group.consumables.find(entities["Consumable"])

    # Finally, return *real* objects, but int he order that was determined to be correct by the #select_rows above
    entity_ids.map do |klass, id|
      case klass
      when "Product"    ; products.detect{|product| product.id.to_s == id.to_s}
      when "Consumable" ; consumables.detect{|consumable| consumable.id.to_s == id.to_s}
      else
        raise "ASSERTION ERROR: was not able to map #{klass.inspect} to Product or Consumable"
      end
    end
  end

  def load_entities_sql
    binds = {
      category_ids: category_ids.map{|cid| quote(cid)}.join(", "),
      group_id:     quote(current_group.id),
      offset:       quote(per_page * page.pred),
      per_page:     quote(per_page.succ),
      q:            quote(q.strip),
    }

    fts = 
      if q.blank?
        Hash.new
      else
        {products: Product.table_name, consumables: Consumable.table_name}.map do |key, table_name|
          [key, "AND to_tsvector('fr', coalesce(#{table_name}.name, '') || ' ' || coalesce(#{table_name}.description, '') || ' ' || coalesce(#{table_name}.building, ' ') || ' ' || coalesce(#{table_name}.aisle, ' ') || ' ' || coalesce(#{table_name}.shelf, ' ') || ' ' || coalesce(#{table_name}.unit, ' ')) @@ plainto_tsquery('fr', #{binds.fetch(:q)})"]
        end.to_h
      end

    <<-EOSQL.squish
      SELECT 'Product', products.id, lower(unaccent(name)) AS sortable_name
      FROM products
      JOIN product_categories on product_categories.product_id = products.id
      WHERE products.group_id = #{binds.fetch(:group_id)}
        #{fts[:products]}
        AND product_categories.category_id IN (#{binds.fetch(:category_ids)})

      UNION ALL

      SELECT 'Consumable', consumables.id, lower(unaccent(name))
      FROM consumables
      JOIN consumable_categories on consumable_categories.consumable_id = consumables.id
      WHERE consumables.group_id = #{binds.fetch(:group_id)}
        #{fts[:consumables]}
        AND consumable_categories.category_id IN (#{binds.fetch(:category_ids)})

      ORDER BY sortable_name
      LIMIT #{binds.fetch(:per_page)}
      OFFSET #{binds.fetch(:offset)}
    EOSQL
  end

  def quote(value)
    ApplicationRecord.connection.quote(value)
  end
end
