event :save_session_votes_after_signup, after: :activate_account do
  save_session_votes
end
