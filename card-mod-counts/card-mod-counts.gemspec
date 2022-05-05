# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "counts" do |s, d|
  s.version = "0.1"
  s.summary = "caching of counts"
  s.description = ""
  d.depends_on_mod :search, :filter
end
