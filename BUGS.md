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

## Remove MiniMagick

MiniMagick should be removed to reduce the application's dependencies. Before
doing so, migrate the image rotation and Active Storage resize flows to a
MiniMagick-free processor, updating the current `resize` geometry options to
the replacement processor's supported transformations. Confirm that the chosen
`image_processing` setup no longer pulls in MiniMagick transitively before
removing the Gemfile dependency.

Affected code:

- `Entities::ImagesController#rotate`
- `Consumables::ImagesController#rotate`
- `WEB_IMAGE_CONFIG` and Active Storage image variants
