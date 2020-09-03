# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-csv_import"
  s.version = "0.8"

  s.authors = ["Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       =  "tool to import csv files "
  s.description   =  "a card mod for importing data from csv files as cards into a deck"
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files = Dir['config/**/*.rb'] + Dir['set/**/*.rb'] + Dir['lib/**/*.rb'] +
            Dir['template/**/*.haml']

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "csv_import" }
  s.add_runtime_dependency "card"
  s.add_runtime_dependency "card-mod-layout"
end
