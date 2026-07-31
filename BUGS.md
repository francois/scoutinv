# Known bugs

## Image upload fails for products and consumables

Uploading an image in a product or consumable create/update action raises a
`TypeError` when the action passes the result of `images.attach` to
`Array#concat`.

`images.attach` does not return an array of `ActiveStorage::Attachment`
records. In Rails 7, it returns `true` when attaching to a persisted, unchanged
record (because it saves immediately), and an
`ActiveStorage::Attached::Changes::CreateMany` object when the record has
pending changes. The attachment call must be separated from collecting the
newly attached records for `ShrinkImageJob`.

Affected code:

- `ProductsController#create` and `#update`
- `ConsumablesController#create` and `#update`
