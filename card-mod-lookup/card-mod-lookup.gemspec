# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "lookup" do |s, d|
  s.version = "0.1"
  s.summary = "lookup"
  s.description = ""
  d.depends_on_mod :filter
end
