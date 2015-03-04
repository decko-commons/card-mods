# -*- encoding : utf-8 -*-

class AddVoted < Card::Migration
  def up
    Card.create! :name=>'*voted up', :codename=>'voted_up'
    Card.create! :name=>'*voted down', :codename=>'voted_down'
  end
end
