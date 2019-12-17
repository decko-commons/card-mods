require 'card/bookmark'

card_accessor :bookmarkers, type: :number

event :toggle_bookmark, :validate, on: :save, trigger: :required do
  abort :failure, "only signed-in users can bookmark" unless Bookmark.ok?
  toggle_bookmarks_item
  add_subcard Bookmark.current_list_card
end

def currently_bookmarked?
  Bookmark.current_ids.include? id
end

def toggle_bookmarks_item
  action = currently_bookmarked? ? :drop : :add
  Bookmark.current_list_card.send "#{action}_item", name
  Bookmark.clear
end

format :html do
  view :bookmark do
    wrap do
      card_form :update, success: { view: :bookmark } do
        [
          hidden_tags(card: { trigger: :toggle_bookmark }),
          field_nest(:bookmarkers, view: :toggle)
        ]
      end
    end
  end

  view :title_with_bookmark, template: :haml

  view :box_top do
    render :title_with_bookmark
  end

  view :bar_left do
    render :title_with_bookmark
  end
end