# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "new_relic" do |s, d|
  s.summary       = "new relic support for decko"
  s.description   = "handle new relic integration with decko decks"
  s.version = "1.1"
  d.depends_on "decko", "newrelic_rpm"
end
