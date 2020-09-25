# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-solid_cache"
  s.version = "0.1"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "solid cache"
  s.description   = ""
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-3.0"]

  s.files         = Dir["{db,set}/**/*.rb"]  + ["README.md"]

  s.required_ruby_version = ">= 2.5.0"
  s.metadata = { "card-mod" => "solid_cache" }

  s.add_runtime_dependency "card"
end
