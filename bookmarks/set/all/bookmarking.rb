def current_bookmarks
  current_bookmark_list.item_cards.each_with_object({}) do |item, hash|
    hash[item.type_id] ||= []
    hash[item.type_id] << item.id
  end
end

def current_bookmark_list
  return [] unless Auth.can_bookmark?

  @current_bookmark_list ||= Auth.current.bookmarks_card
end
