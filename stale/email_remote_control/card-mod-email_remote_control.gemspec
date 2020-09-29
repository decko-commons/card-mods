# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-email_remote_control"
  s.version = "0.1"

  s.authors = ["Ethan McCutchen", "Philipp Kühl"]
  s.email = ["info@decko.org"]

  s.summary       = "make card changes via email"
  s.description   = "You can send emails to your deck and it will create a card with" \
                    "the email's subject as name and its body as content."
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["config/**/*.rb"] + Dir["lib/**/*.rb"] + Dir["set/**/*.rb"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "email_remote_control" }

  %w[card nokogiri rufus-scheduler].each do |n|
    s.add_runtime_dependency n
  end
end
