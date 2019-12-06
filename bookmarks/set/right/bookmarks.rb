include Abstract::IdPointer

def item_cards_of_type type
  type_id = Card.fetch_id type
  item_cards.select { |i| i.type_id == type_id }
end