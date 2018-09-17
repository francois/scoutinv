class FixObjectSlugs < ActiveRecord::Migration[5.2]
  def up
    [Category, Event, Group, Instance, Member, Membership, Note, Product, Reservation, Troop].each do |klass_name|
      klass_name.where("slug ~* '[^a-z0-9]'").each do |object|
        object.slug = object.generate_slug
        object.save!
      end
    end
  end

  def down
    # NOP
  end
end
