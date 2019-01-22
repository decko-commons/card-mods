# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-markdown"
  s.version = "0.2"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "markdown support for decko"
  s.description   = "use markdown in decko card content"
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["config/**/*.rb"] + Dir["lib/**/*.rb"] + Dir["set/**/*.rb"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "markdown" }

  %w[card kramdown].each do |n|
    s.add_runtime_dependency n
  end
end
