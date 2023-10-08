# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'faker'
# Même aléatoire à chaque fois
Faker::Config.random = Random.new(42)

## Dans une task
# Group root
# si pas de superuser dans keycloak
  # Superuser
  # Créer superuser dans Keycloak avec mdp temporaire
# Si pas de roles dans Keycloak
  # Roles
  # Assignation des roles

unless Rails.env.production?
  # Drop les tables
  [Client, Group].each do |model|
    model.destroy_all
    ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
  end



  # Clients
  # Groups pour clients
  # Admin pour clients
  # User pour clients
  # Créer les users dans keycloak avec les attributs
  # Machines pour clients

  groups = []
  groups_id = [nil, 0, 1, 2, 1, nil, 5, 5, 7, 7]
  (0..9).each do |i|
    groups << {id: i, name: Faker::Lorem.words(number: 2).join(' '), group_id: groups_id[i]}
  end
  Group.create(groups)

  clients = []
  (0..1000).each do
    clients << {name: Faker::Name.name, address: Faker::Address.full_address, group_id: Faker::Number.digit}
  end
  Client.create(clients)

end