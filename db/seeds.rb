tentes      = Category.create(name: "Tentes")
cuisine     = Category.create(name: "Cuisine")
chauffage   = Category.create(name: "Chauffage")

fleurimont  = Group.create!(name: "10ème Groupe Scout Est-Calade")
francois    = fleurimont.users.create!(email: "francois@teksol.info",  name: "Le Chouette Baloo", password: "monkey", password_confirmation: "monkey")
claudette   = fleurimont.users.create!(email: "claudette@teksol.info", name: "Claudette",         password: "monkey", password_confirmation: "monkey")

tente1 = fleurimont.products.create!(name: "Tente 4x5 6 personnes (#1)")
tente1.categories = [ tentes ]

tente2 = fleurimont.products.create!(name: "Tente 4x5 6 personnes (#2)")
tente1.categories = [ tentes ]

pot_lait1 = fleurimont.products.create!(name: "Pot à lait #1")
pot_lait1.categories = [ cuisine ]

pot_lait2 = fleurimont.products.create!(name: "Pot à lait #1")
pot_lait2.categories = [ cuisine ]

rond_de_feu = fleurimont.products.create!(name: "Rond de feu")
rond_de_feu.categories = [ chauffage, cuisine ]

rock_forest = Group.create!(name: "47ème Groupe Scout Rock-Forest")
tenterf1    = rock_forest.products.create!(name: "Tente prospecteur #1")
tenterf2    = rock_forest.products.create!(name: "Tente prospecteur #2")

st_elie     = Group.create!(name: "48ème Groupe Scout Les Rassembleurs")
