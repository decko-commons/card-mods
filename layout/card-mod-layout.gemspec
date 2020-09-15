# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-layout"
  s.version = "0.5"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "layout tables in decko"
  s.description   = ""
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["db/**/*.rb"] + Dir["lib/**/*.rb"] + Dir["set/**/*.rb"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "layout" }
end
