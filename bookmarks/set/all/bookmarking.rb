def current_bookmarks
  bookmark_list do
    current_bookmark_list.item_cards.each_with_object({}) do |item, hash|
      hash[item.type_id] ||= []
      hash[item.type_id] << item.id
    end
  end
end

def current_bookmark_list
  @current_bookmark_list ||= bookmark_list { Auth.current.bookmarks_card }
end

def bookmark_list
  Auth.can_bookmark? ? yield : []
end
