# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-pdfjs"
  s.version = "1.0"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "pdfjs support for decko"
  s.description   = "render pdf files attached to file cards with pdfjs"
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["set/**/*.rb"] + Dir["files/**/*.rb"] + ["README.md"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "pdfjs" }

  s.add_runtime_dependency "card"
end
