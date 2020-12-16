# -*- encoding : utf-8 -*-

class InstallBookmarks < Cardio::Migration
  def up
    ensure_code_card "Bookmarks"
    ensure_code_card "Bookmarkers"
  end
end
