include_set Abstract::VoteCountExport

def virtual?
  true
end

format :csv do
  view :core do
    res = []
    type_id = card.left.id
    all_votes do |user, vote, dir|
      next unless vote.type_id == type_id
      res << CSV.generate_line([user.id, vote.id, dir, vote.created_at])
    end
    res.join
  end
end
