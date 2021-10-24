# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "bookmarks" do |s, d|
  s.version = 1.1
  s.summary       = "bookmarking on decko cards"
  s.description   = "WikiRate.org is driving development on this to-be-generalized " \
                    "decko bookmarking tool."
  d.depends_on_mod :counts
end
