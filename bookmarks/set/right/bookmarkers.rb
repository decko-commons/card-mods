def active?
  left&.currently_bookmarked?
end

format :html do
  view :toggle, template: :haml

  def bookmark_status_class
    card.active? ? "active-bookmark" : "inactive-bookmark"
  end
end
