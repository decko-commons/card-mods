# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "google_analytics" do |s, d|
  s.version = "0.2"
  s.summary = "Google Analytics support for decko"
  s.description = ""
  d.depends_on ["staccato", "~> 0.5"]
end
