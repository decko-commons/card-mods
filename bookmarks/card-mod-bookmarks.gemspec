# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-bookmarks"
  s.version = "0.1"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "bookmarking on decko cards"
  s.description   = "WikiRate.org is driving development on this to-be-generalized " \
                    "decko bookmarking tool."
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["set/**/*.rb"] + Dir["db/**/*.rb"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "bookmarks" }

  s.add_runtime_dependency "card"
end
