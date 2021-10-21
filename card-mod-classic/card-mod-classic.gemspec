# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "classic" do |s, d|
  s.version = "0.14"
  s.summary = "Classic decko mods"
  s.description = ""
  d.depends_on_mod :default, :alias, :prosemirror, :google_analytics, :legacy
end
