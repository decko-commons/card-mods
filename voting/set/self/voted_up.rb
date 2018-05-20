include_set Abstract::FollowOption

self.restrictive_follow_opts :position=>3

self.follower_candidate_ids do |card|
  Card.search :right_plus=>[ Card[:upvotes].name, { :refer_to=>card.name } ], :return=>:id
end


def title
  'Following content you voted up'
end

def label
  "follow if I voted up"
end

def description set_card
  "#{set_card.follow_label} I voted up"
end