# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "graphql" do |s, d|
  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.version = "0.2"
  s.summary = "GraphQL for decko cards"
  s.description = ""
  d.depends_on ["graphql", "~> 1.12.20"],
               ["graphiql-rails", "~> 1.7"],
               "rack-cors"
end
