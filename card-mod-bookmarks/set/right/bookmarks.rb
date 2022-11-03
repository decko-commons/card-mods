include_set Abstract::IdList

assign_type :list

def history?
  false
end

def followable?
  false
end

def item_cards_of_type type
  type_id = type.card_id
  item_cards.select { |i| i.type_id == type_id }
end
