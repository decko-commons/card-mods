# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-logger"
  s.version = "1.0"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "request and performance logger for decko"
  s.description   = "customizable logging of decko request and performance meta data"
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["db/**/*.rb"] + Dir["lib/**/*.rb"] + Dir["set/**/*.rb"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "logger" }
  s.add_runtime_dependency "card"
end
