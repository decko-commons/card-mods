include Card::FollowOption

self.restrictive_follow_opts :position=>3

def applies_to? card, user_id
  (user= Card.fetch user_id.to_i) && (user.upvotes_card.include_item?(card) || user.downvotes_card.include_item?(card))
end

def title
  'Following content you voted for'
end

def label
  "follow what I've voted for"
end

def description set_card
  "#{set_card.follow_label} I voted for"
end