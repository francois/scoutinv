# This migration comes from active_storage (originally 20180723000244)
class AddForeignKeyConstraintToActiveStorageAttachmentsForBlobId < ActiveRecord::Migration[6.0]
  def up
    return if foreign_key_exists?(:active_storage_attachments, column: :blob_id)

    if table_exists?(:active_storage_blobs)
      execute <<~SQL
        DELETE FROM active_storage_attachments
        WHERE NOT EXISTS (
          SELECT 1
          FROM active_storage_blobs
          WHERE active_storage_blobs.id = active_storage_attachments.blob_id
        )
      SQL

      add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    end
  end
end
