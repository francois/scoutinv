# Scoutinv Agent Guide

## Application at a glance

Scoutinv is a multi-tenant inventory and rental application for Scout groups. Members authenticate with a one-time email link, then manage their group's reusable products, consumables, events, reservations, and reports. The default UI locale is French; English is also supported.

This is a Rails 7.0 monolith, not an API application:

- Ruby is pinned to `3.0.7` in `.ruby-version`; Rails is `~> 7.0.10`.
- PostgreSQL is required. `db/structure.sql` is the schema source and uses the `citext` and `unaccent` extensions.
- Server-rendered ERB, Sprockets, Foundation 6, jQuery, Rails UJS, and Turbolinks make up the UI. `package.json` has no frontend dependencies or build step.
- Tests use Minitest fixtures, integration tests, and a small Selenium/Capybara system-test suite.
- Active Storage handles images. Que/PostgreSQL runs background jobs. Prawn generates event contract PDFs.

The README records the currently supported Rails/Ruby/PostgreSQL baseline; follow the Gemfile and `.ruby-version` for the exact local runtime.

## Setup and running

Development and test environment variables are supplied through `.env.development` and `.env.test` via `dotenv-rails`. They define at least `DATABASE_URL` and `MAIL_FROM`; do not print or commit their values. The default URLs in `config/database.yml` are `scoutinv_development` and `scoutinv_test` on local PostgreSQL.

```sh
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Use the pinned Ruby runtime when installing or running commands. If the shell is on a newer default Ruby, prefer:

```sh
rvm use ruby-3.0.7 do bundle install
```

`bin/setup` installs gems, runs `db:setup`, clears logs/tmp files, and restarts Rails. Run the worker alongside the server when exercising email, image processing, or event transitions:

```sh
bundle exec que --worker-count 2
```

The `Procfile` defines the Heroku process types: `web`, `worker`, and a `release` migration step. Production also requires mail settings, `CANONICAL_HOST`, and Rails credentials for S3 when that storage service is selected.

## Verification

```sh
bin/rails test
bin/rails test test/models/event_test.rb
bin/rails test test/controllers/events/reservations_controller_test.rb
```

Tests require a reachable PostgreSQL test database. The Selenium/Capybara system tests are currently broken and are not part of the upgrade verification; the remaining test suite must pass. There is no configured linting or JavaScript test command. Add focused model or integration tests for behavior changes; use existing YAML fixtures in `test/fixtures` and `LoginTestHelper` for authenticated controller flows. Several system tests are legacy-generated and should be treated carefully when expanding coverage.

## Structure and domain rules

- `app/controllers` coordinates requests, parameter whitelisting, rendering, and redirects. `ApplicationController` establishes `current_member` and `current_group`.
- `app/models` contains the domain behavior. State-changing operations generally live on aggregates such as `Group`, `Event`, `Product`, `Consumable`, or `Instance`, rather than in controllers.
- `Group` is the tenant boundary. Fetch application records through `current_group` (for example, `current_group.products.find_by!(slug: ...)`) to prevent cross-group access. `Category` is shared globally.
- Public routes use opaque `HasSlug` slugs through `to_param`; do not assume an `:id` parameter is a numeric primary key.
- `Group#register_new_*` and model mutation methods append `DomainEvent` records. Controllers pass `domain_event_metadata`; preserve this pattern and group related writes inside transactions.
- Products are reusable inventory represented by multiple `Instance` records. Instances have the `available`, `held`, `repairing`, and `trashed` lifecycle. Changing a product quantity creates or removes instances through callbacks.
- Consumables use immutable-style `ConsumableTransaction` entries and `Quantity` value objects with SI-prefix conversion. Inventory on hand is derived from transactions, not a mutable stock field.
- Events represent an internal troop or external renter and transition `draft -> final/ready -> returned`. Reservation edits and lifecycle operations must keep `Event` authorization methods, reservation overlap logic, and Que notifications consistent.
- Reservation availability is based on the event's pickup-to-return date range, not only its start/end dates. The app intentionally reports double-booking conflicts rather than silently resolving them.
- `EntitySearchService` uses PostgreSQL-specific SQL/full-text search and returns a combined Product/Consumable result set. Preserve its ordering, pagination (`per_page + 1`), and tenant/category filters when modifying it.

## UI, localization, and jobs

- Add user-facing copy to both `config/locales/fr.yml` and `config/locales/en.yml`; prefer scoped `t(".key")` lookups in views/controllers. Default locale is French and the locale is selected from `params[:locale]` or the `Accept-Language` header.
- Follow existing ERB partial and Foundation grid/button conventions. JavaScript belongs under `app/assets/javascripts`; styles belong under `app/assets/stylesheets` and are included by Sprockets manifests.
- Event pages and reservation controls have both HTML and `.js.erb` response paths. Preserve both where changing interactive reservation behavior.
- Background jobs subclass `ApplicationJob`/`Que::Job` and implement `run`; queue them with Que's existing `enqueue` convention. Jobs are responsible for destroying themselves after successful execution when appropriate.
- Images use Active Storage variants and `ShrinkImageJob`; keep attachment work and image processing compatible with local/test/S3 storage configurations.

## Change discipline

- Use SQL migrations and update `db/structure.sql` through Rails migration tooling; do not hand-edit generated schema output.
- Match the repository's Ruby style: simple classes, explicit transactions, keyword metadata arguments, and Minitest `test "..."` cases. Avoid introducing APIs that Rails 7.0 or Ruby 3.0 do not support.
- Authentication is passwordless and CSRF verification is globally disabled in the legacy application. Do not broaden public access or bypass `current_group` scoping when adding endpoints.
- Review the deployment-sensitive effects of changes to mail, Active Storage, Que jobs, PDFs, and PostgreSQL full-text search. Validate the narrowest relevant tests before broader suite runs.
