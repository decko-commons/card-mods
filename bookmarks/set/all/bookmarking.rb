def current_bookmark_list
  return unless Auth.can_bookmark?

  @current_bookmark_list ||= Auth.current.bookmarks_card
end

def current_bookmark_ids
  bookmark_items { current_bookmark_list.item_ids }
end

def current_bookmarks_of_type type
  bookmark_items { current_bookmark_list.item_cards_of_type type }
end

def current_bookmark_names_of_type type
  current_bookmarks_of_type(type).map(&:name)
end

def bookmark_items
  Auth.can_bookmark? ? yield : []
end

format do
  delegate :current_bookmarks_of_type, :current_bookmark_names_of_type, to: :card
end