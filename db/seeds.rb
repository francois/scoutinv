tent    = Category.create(name: "tent")
kitchen = Category.create(name: "kitchen")
misc    = Category.create(name: "miscellaneous")

fleurimont = Group.create!(name: "10ème Groupe Scout Est-Calade")
francois   = fleurimont.members.create!(email: "francois@teksol.info",  name: "Le Chouette Baloo")
claudette  = fleurimont.members.create!(email: "claudette@teksol.info", name: "Claudette")

tente1 = fleurimont.products.create!(name: "Tente 4x5 6 personnes (#1)")
tente1.categories = [ tent ]

tente2 = fleurimont.products.create!(name: "Tente 4x5 6 personnes (#2)")
tente1.categories = [ tent ]

pot_lait1 = fleurimont.products.create!(name: "Pot à lait #1")
pot_lait1.categories = [ kitchen ]

pot_lait2 = fleurimont.products.create!(name: "Pot à lait #1")
pot_lait2.categories = [ kitchen ]

rond_de_feu = fleurimont.products.create!(name: "Rond de feu")
rond_de_feu.categories = [ misc, kitchen ]

rock_forest = Group.create!(name: "47ème Groupe Scout Rock-Forest")
tenterf1    = rock_forest.products.create!(name: "Tente prospecteur #1")
tenterf2    = rock_forest.products.create!(name: "Tente prospecteur #2")

st_elie     = Group.create!(name: "48ème Groupe Scout Les Rassembleurs")
