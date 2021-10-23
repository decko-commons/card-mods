# cache # of users who have bookmarked this metric/topic/whatever(=left)
include_set Abstract::TaggedByCachedCount, type_to_count: :user,
                                           tag_pointer: :bookmarks,
                                           count_trait: :bookmarkers

def active?
  left&.currently_bookmarked?
end

format :html do
  view :toggle, cache: :never, template: :haml

  def bookmark_status_class
    card.active? ? "active-bookmark" : "inactive-bookmark"
  end
end
