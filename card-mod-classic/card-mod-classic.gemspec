# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "classic" do |s, d|
  s.version = "0.14"
  s.summary = "Classic decko mods"
  s.description = ""
  d.depends_on_mod :alias, :defaults, :google_analytics, :prosemirror_editor
end
