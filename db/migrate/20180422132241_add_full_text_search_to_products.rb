class AddFullTextSearchToProducts < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE EXTENSION unaccent"
    execute "CREATE TEXT SEARCH CONFIGURATION fr ( COPY = french )"
    execute "ALTER TEXT SEARCH CONFIGURATION fr ALTER MAPPING FOR hword, hword_part, word WITH unaccent, french_stem"
    execute "CREATE INDEX index_products_on_name ON products USING gin(to_tsvector('fr', coalesce(name, '') || ' ' || coalesce(description, '') || ' ' || coalesce(aisle, ' ') || ' ' || coalesce(shelf, ' ') || ' ' || coalesce(unit, ' ')))"
  end
end
