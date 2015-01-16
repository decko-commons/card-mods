# -*- encoding : utf-8 -*-

class AddMarkdownType < Wagn::Migration
  def up
    Card.create! :name=>'Markdown', :codename=>'markdown', :type_id=>Card::CardtypeID
  end
end
