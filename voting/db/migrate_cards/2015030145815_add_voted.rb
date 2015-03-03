# -*- encoding : utf-8 -*-

class AddVoted < Card::Migration
  def up
    Card.create! :name=>'*voted', :codename=>'voted'
  end
end
