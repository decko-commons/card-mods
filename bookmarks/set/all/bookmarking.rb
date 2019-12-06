def current_bookmark_list
  return unless Auth.can_bookmark?

  @current_bookmark_list ||= Auth.current.bookmarks_card
end

def current_bookmarks_of_type type
  return [] unless Auth.can_bookmark?

  current_bookmark_list.item_cards_of_type type
end

def current_bookmarks_names_of_type type
  current_bookmarks_of_type(type).map(&:name)
end