# Consumables

Consumables represent "stuff" that doesn't have an identity. Consumables,
as their name suggests, are consumed after being checked out on an event.
This in contrast with Products, which have an identity and can be reused
often and also have a lifecycle: available, checked out, in repair and
trashed.

## Constraints

Consumables must be able to be consumed in different units than what
was added to inventory, for instance, the Group buys 35 kg of beef.
A troop requests 2700 g. The system should be able to calculate the
correct unit price (in 100 g or 1000 g units in this case), and
properly deduct inventory.

This requires adding some kind of units to the system, so that it
can convert between different units.

# Proposal

Consumable model + Consumable Transaction model.

Consumable describes the consumable (similar to Product).

Consumable Transaction records the in/out activity for a given Consumable (kind of but not quite like Instance).

e.g.:

1. Create consumable (beef patties)
2. Add inventory (ConsumableTransaction, delta +100)
3. Use some consumable in an event (ConsumableTransaction, delta -25)
4. Current quantity available = sum(ConsumableTransaction.delta) = 75

Consumables can be added to Categories, same as Product.

## `Product` becomes a STI

Product and Consumable are very similar, except in one respect: Product exist
beyond a given Event. To support this use case, it is proposed that Product
become an STI class, with the following columns added:

    rename_table :products, :entities

    add_column :entities, :type, :text, null: false, default: 'Product'
    add_column :entities, :unit_price_si_prefix, :text, null: false, default: ""
    add_column :entities, :unit_price_unit, :text, null: false, default: "unit"

    execute <<~EOSQL
      ALTER TABLE entities
          ALTER COLUMN unit_price_si_prefix
            ADD CONSTRAINT CHECK(unit_price_si_prefix in ('milli', 'centi', 'deci', '', 'kilo'))
        , ALTER COLUMN unit_price_unit
            ADD CONSTRAINT CHECK(unit_price_unit in ('unit', 'gram', 'litre', 'pound'))
    EOSQL

Those columns describe how a given Product is priced. This is more relevant
to Consumable than on Product, but the system doesn't forbid it. Of course,
reserving a kilounit of tents doesn't make much sense, so some care must
be taken to prevent silly mistakes.

The following changes will also be introduced to the system:

    # Rename Product to Entity
    class Entity < ApplicationRecord
      include HasSlug

      validates :unit_price_unit, :unit_price_si_prefix, presence: true
      validates :unit_price_unit, in: %w(unit gram litre pound)
      validates :unit_price_si_prefix, in: ["milli", "", "kilo"]

      # Keep any validations and scopes that aren't specific to
      # instances or reservations.
    end

    # Introduce new Product, move anything related to reservation
    # and instance on the Product class itself.
    class Product < Entity
      has_many :instances
      has_many :reservations

      # Move any scopes and validations that are related to
      # instances and reservations
    end

    class Consumable < Entity
      has_many :transactions, class_name: "ConsumableTransaction"
      belongs_to :event
    end

    class ConsumableTransaction < ApplicationRecord
      belongs_to :consumable
      belongs_to :event

      validates :delta, numericality: { only_integer: false, allow_blank: false }
      validate :event_or_description

      private

      def event_or_description
        return if event.present?
        return if description.present?

        errors.add(:event, "is required, unless description is provided")
      end
    end

## `consumable_transactions` schema

    id bigserial not null primary key
    product_id bigint not null foreign key(products)
    event_id bigint foreign key(events)
    description text
    delta numeric not null
    created_at timestamp with time zone not null default current_timestamp
    updated_at timestamp with time zone not null default current_timestamp

Validations require either `event_id` OR `description` to be filled in.
When `event_id` is NULL, this indicates a manual transaction and requires
an explanation of what actually went on. When `event_id` is not NULL,
this indicates the consumable was used in the context of a specific event,
and that is sufficient explanation.

`consumable_transactions` are immutable once written to the database.

## Reservations against Consumables

It is currently very unwieldy to make Reservation work as-is against
Consumables. The Reservation is tied to an instance, not a Product.

Instead, we will introduce a Withdrawal object, which will record the
information needed to process the checkout later. Withdrawals are
recorded as:

    id bigserial not null primary key
    event_id bigint not null references events
    product_id bigint not null references products
    quantity numeric not null
    si_prefix text not null default '' check(si_prefix in ('milli', 'centi', 'deci', '', 'kilo'))
    checkout_on date
    created_at timestamp with time zone not null default current_timestamp
    updated_at timestamp with time zone not null default current_timestamp

UX-wise, Consumables will be shown in-line with other products, and
the server will handle the complexity of reserving an Instance or a
Consumable. This will require refactoring the `Event#reserve`,
`#offer`, `#lease_all` and `#lease` methods to delegate to the
Product.

`Event#return` makes sense for Consumables as well, when it is non-perishable.
Think cans of soup: we can return those after an event and we can reuse them
later on.

The server must validate the available quantity from all events that
have not yet checked out their Consumable, irrespective of their
relative dates.

    class Withdrawal < ApplicationRecord
      belongs_to :product
      belongs_to :event

      validates :product, :event, presence: true
      validates :quantity, presence: true, numericality: { only_integer: false, allow_blank: false }
    end

    class Consumable < Product
      has_many :withdrawals

      def available
        level - reserved
      end

      def level
        transactions
          .map(&:delta)
          .sum
      end

      def reserved
        withdrawals
          .reject(&:checkout_on)
          .map(&:quantity)
          .sum
      end
    end

    class Event < Product
      has_many :withdrawals
    end

To determine the current availability of a Consumable, we must take into account
the current availability in the inventory as well as any non-checked out
withdrawals.

## Consumables Report

The following query returns the Consumables report:

    SELECT
        products.*
      , coalesce(available.quantity, 0) AS level
      , coalesce(reserved.quantity, 0) AS reserved
      , coalesce(available.quantity, 0) - coalesce(reserved.quantity, 0) AS available
    FROM products
    LEFT JOIN (
        SELECT product_id, sum(delta) AS quantity
        FROM consumable_trnansactions
        GROUP BY product_id) AS available ON available.product_id = products.id
    LEFT JOIN (
        SELECT product_id, sum(quantity) AS quantity
        FROM events
        JOIN withdrawals
        WHERE checkout_on IS NULL
        GROUP BY product_id) AS reserved
    WHERE products.type = 'Consumable'
