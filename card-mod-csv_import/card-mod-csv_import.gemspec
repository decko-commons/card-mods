# -*- encoding : utf-8 -*-

require "../card_mod_gem"

CardModGem.mod "csv_import" do |s, d|
  s.version = "0.9"
  s.summary = "tool to import csv files "
  s.description = "a card mod for importing data from csv files as cards into a deck"
  d.depends_on_mod :tabs
end
