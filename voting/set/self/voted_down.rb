include Card::FollowOption

self.restrictive_follow_opts :position=>3

def applies_to? card, user_id
  (user= Card.fetch user_id.to_i) &&  user.downvotes_card.include_item?(card.id)
end

def title
  'Following content you voted down'
end

def label
  "follow if I voted down"
end

def description set_card
  "#{set_card.follow_label} I voted down"
end