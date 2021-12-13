event :save_session_bookmarks, :integrate, on: :create do
  session_bookmark_card = Card[:anonymous].bookmarks_card
  return if session_bookmark_card.item_names.blank?

  left.subfield :bookmarks, type: :list, content: session_bookmark_card.content
end
