include Abstract::FollowOption

restrictive_follow_opts :position=>3

follower_candidate_ids do |card|
  Card.search({ right_plus: [Card[:downvotes].name, { refer_to: card.name }],
                return: :id },
              "follower candidate ids for #{card.name}")
end

def title
  'Following content you voted down'
end

def label
  'follow if I voted down'
end

def description set_card
  "#{set_card.follow_label} I voted down"
end
