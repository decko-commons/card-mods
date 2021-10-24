include_set Abstract::FollowOption

restrictive_follow_opts position: 3

follower_candidate_ids do |card|
  Card.search({ right_plus: [:bookmarks, { refer_to: card.name }], return: :id },
              "bookmarked follower candidate ids for #{card.name}")
end

def title
  'Following content you bookmarked'
end

def label
  'follow if I bookmarked'
end

def description set_card
  "#{set_card.follow_label} I bookmarked"
end
