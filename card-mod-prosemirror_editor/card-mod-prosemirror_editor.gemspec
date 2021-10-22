# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "prosemirror_editor" do |s, d|
  s.version = "0.14"
  s.summary = "Prose Mirror editor"
  s.description = ""
  d.depends_on_mod :edit
end
