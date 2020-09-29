format :csv do
  view :core do
    res = []
    all_votes do |user, vote, dir|
      res << CSV.generate_line([user.id, vote.id, dir, vote.created_at])
    end
    res.join
  end

  def all_votes
    all_users.each do |user|
      user.upvotes_card.item_names.each do |name|
        next unless (vote = Card.quick_fetch(name))
        yield user, vote, "up"
      end
      user.downvotes_card.item_names.each do |name|
        next unless (vote = Card.quick_fetch(name))
        yield user, vote, "down"
      end
    end
  end

  def all_users
    Card.search({ type_id: Card::UserID }, 'all users')
  end
end
