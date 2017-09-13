# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-new_relic"
  s.version = "1.0"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "new relic support for decko"
  s.description   = "handle new relic integration with decko decks"
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["set/**/*.rb"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "new_relic" }

  s.add_runtime_dependency "decko"
  s.add_runtime_dependency "newrelic_rpm"
end
