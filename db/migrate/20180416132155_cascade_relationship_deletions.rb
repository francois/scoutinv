class CascadeRelationshipDeletions < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :events, :groups
    add_foreign_key :events, :groups, on_update: :cascade, on_delete: :cascade

    remove_foreign_key :members, :groups
    add_foreign_key :members, :groups, on_update: :cascade, on_delete: :cascade

    remove_foreign_key :products, :groups
    add_foreign_key :products, :groups, on_update: :cascade, on_delete: :cascade

    remove_foreign_key :reservations, :events
    add_foreign_key :reservations, :events, on_update: :cascade, on_delete: :cascade

    remove_foreign_key :notes, :members
    add_foreign_key :notes, :members, column: :author_id, on_update: :cascade, on_delete: :cascade

    remove_foreign_key :member_sessions, :members
    add_foreign_key :member_sessions, :members, on_update: :cascade, on_delete: :cascade

    remove_foreign_key :product_categories, :products
    add_foreign_key :product_categories, :products, on_update: :cascade, on_delete: :cascade

    remove_foreign_key :reservations, :products
    add_foreign_key :reservations, :products, on_update: :cascade, on_delete: :cascade
  end

  def down
    remove_foreign_key :events, :groups
    add_foreign_key :events, :groups

    remove_foreign_key :members, :events
    add_foreign_key :members, :events

    remove_foreign_key :products, :groups
    add_foreign_key :products, :groups

    remove_foreign_key :reservations, :events
    add_foreign_key :reservations, :events

    remove_foreign_key :notes, :members
    add_foreign_key :notes, :members, column: :author_id

    remove_foreign_key :member_sessions, :members
    add_foreign_key :member_sessions, :members

    remove_foreign_key :product_categories, :products
    add_foreign_key :product_categories, :products

    remove_foreign_key :reservations, :products
    add_foreign_key :reservations, :products
  end
end
