# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-voting"
  s.version = "1.0"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "up-down voting on decko cards"
  s.description   = "WikiRate.org is driving development on this to-be-generalized " \
                    "decko voting tool."
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["set/**/*.rb"] + Dir["db/**/*.rb"] + ["README.md"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "voting" }

  s.add_runtime_dependency "card"
end
