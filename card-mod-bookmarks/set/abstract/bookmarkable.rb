card_accessor :bookmarkers # , type: :search_type

event :toggle_bookmark, :prepare_to_validate, on: :save, trigger: :required do
  toggle_bookmarks_item
  list = Card::Bookmark.current_list_card
  if Auth.signed_in?
    list.save!
  else
    # when using save!, session card was getting saved to db
    list.store_in_session
    abort :triumph
  end
end

def currently_bookmarked?
  Card::Bookmark.current_ids.include? id
end

format :html do
  view :bookmark, wrap: :slot do
    link_to_view :bookmark, field_nest(:bookmarkers, view: :toggle),
                 class: "slotter _stop_propagation",
                 path: { action: :update, card: { trigger: :toggle_bookmark } }
  end

  view :title_with_bookmark, template: :haml

  view :box_top do
    render :title_with_bookmark
  end

  view :bar_left do
    render :title_with_bookmark
  end
end

private

def toggle_bookmarks_item
  action = currently_bookmarked? ? :drop : :add
  Card::Bookmark.current_list_card.send "#{action}_item", name
  Card::Bookmark.clear
end
