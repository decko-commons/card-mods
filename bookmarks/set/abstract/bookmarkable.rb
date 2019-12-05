card_accessor :bookmarkers, type: :number

event :toggle_bookmark, :validate, on: :save, trigger: :required do
  abort :failure, "only signed-in users can bookmark" unless can_bookmark?
  toggle_bookmarks_item
  add_subcard current_bookmark_list
end

def can_bookmark?
  Auth.signed_in? && Auth.current.type_id == UserID
end

def current_bookmark_list
  @current_bookmark_list ||= Auth.current.bookmarks_card
end

def currently_bookmarked?
  current_bookmark_list.item_names.include? name
end

def toggle_bookmarks_item
  action = currently_bookmarked? ? :drop : :add
  current_bookmark_list.send "#{action}_item", name
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
end
