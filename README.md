# Scoutinv

This application enables a Scout Group to manage their inventory. Scout Troop Masters create events
(camps) and reserve products. The application is responsible for flagging overlapping reservations
and letting humans take care of the rest. Inventory Masters are responsible for managing the actual
data-entry of the inventory: pictures, description, etc.

Security is minimal: beyond being associated with a single Scout Group, all Members in the same Group
can do everything: manage inventory, reserve products, create events, etc.

## Main Use Cases

* Member adds Product to inventory
    - Products belong to 0..N categories
    - Products have a description
    - Products may have 0..N pictures
* Member adds Member to Group
    - Email, password, name
* Member removes Member from Group
    - Last member can't be removed
    - Can't remove self
    - Can't remove a member that doesn't belong to the member's group
* Member registers Event
    - Events have a name/description
    - Events start and end on specific dates
* Member browses Products
    - Products that are already reserved for the same date range are dimmed, to
        indicate unavailability
    - The product list may be filtered to a single Category
    - The product list may be filtered to products whose name match a substring
        searching for: "ten" return "4x10 winter tent" and "gluten free rope"
    - Reserving an already reserved Product is allowed, as the tool is only there
        to help planning
* Member can view a single Product's history
    - Displays a history of this product's reservations
    - Displays any notes associated with each reservation
* Member reserves Product for Event
* Member sends reservation request
    - The reservation request is sent to one or more people
    - The reservation request email has a link to see the list of products
    - The reservation request email can be printed as a check list for easy
        on-the-ground marking and note taking
    - The reservation request contains a short alpha-numeric string that identifies
        it and can be used to return to the same list later (think bit.ly short code)
* Member browses list of Events
    - List displays events that have closed in the past two weeks and all future events
* Member prints a reservation list for a specific Event
    - Each product on the list has a checkbox, for easy bookkeeping while on-site
* Member adds a Note on a Product in an Event
    - Indicates future repairs or things that may have happened to the Product
    - It may be easier to display the reservation list and have a Notes field
        next to each event
* Member adds a Note on a Product
    - The Note is not tied to any specific Event
* Admin adds Product Category
* Member registers Group
    - Must provide both Group and Member details in one screen, so that the
        Group and it's first Member can be bootstrapped
* Admin adds Group
* Admin registers first Member in Group
    - Email, password, name
* Admin removes Member from Group

## Product Examples

Scout Groups should record every possible products that a Scout Troop can take with them when they
go on an expedition:

* Flags
* Tents
* Kitchen ustensils
* Propane tanks
* Projectors
* etc.

# Technical Notes

This is a Ruby on Rails 5.2 application, running on Ruby 2.5 and using PostgreSQL 10.x.
The application is styled using [ZURB Foundation 6.4.3](https://foundation.zurb.com/sites/docs/index.html).

The application is deployed to Heroku, on the free tier (10k rows, 18 hours of uptime per day).

Because of the open source nature of Scoutinv, you are free to host your own copy.

## Development

Clone this repository, then run `bundle install`. Make sure you have a PostgreSQL database
available somewhere, and then run:

    # Clone the repository
    git clone https://gitlab.com/francoisb/scoutinv.git
    cd scoutinv

    # Install dependencies
    bundle install

    # Setup the database
    # NOTE: This is the default database URL, change as you see fit
    export DATABASE_URL=postgresql://localhost:5432/scoutinv_development
    rails db:create db:migrate db:seed
    rails server

After that, visit http://localhost:3000/ and start coding.
