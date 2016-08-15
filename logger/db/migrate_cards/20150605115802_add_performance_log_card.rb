# -*- encoding : utf-8 -*-

class AddPerformanceLogCard < Card::Migration::Core
  def up
    if card = Card['*performance log']
      card.update_attributes! :type_code=>:pointer, :codename=>:performance_log
    else
      Card.create! :name=>'*performance log', :type_code=>:pointer, :codename=>:performance_log
    end
  end
end
