# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-airbrake"
  s.version = "1.0"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       =  "airbrake support for decko"
  s.description   =  "a card mod to send error messages to airbrake"
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files = Dir['config/**/*.rb'] + Dir['set/**/*.rb']

  s.required_ruby_version = ">= 2.3.0"
  s.add_runtime_dependency "airbrake", "~> 6.2"
  s.metadata = { "card-mod" => "airbrake" }
  s.add_runtime_dependency "card"
end
