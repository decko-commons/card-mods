card_accessor :bookmarkers, type: :number

event :toggle_bookmark, :validate, on: :save, trigger: :required do
  abort :failure, "only signed-in users can bookmark" unless Auth.can_bookmark?
  toggle_bookmarks_item
  add_subcard current_bookmark_list
end

def currently_bookmarked?
  return false unless real? && Auth.can_bookmark?

  current_bookmarks.values.flatten.include? id
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

module ::Card::Auth
  def self.can_bookmark?
    signed_in? && current.respond_to?(:bookmarks_card)
  end
end
