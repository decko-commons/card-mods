# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "filter" do |s, d|
  s.version = "0.3"
  s.summary = "filter"
  s.description = ""
  d.depends_on_mod :search, :bootstrap
end
