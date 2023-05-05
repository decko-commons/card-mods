# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "export" do |s, d|
  s.version = "0.2"
  s.summary = "export"
  s.description = ""
  d.depends_on_mod :search
end
