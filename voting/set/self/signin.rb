event :save_session_votes_after_signin, :before=>:signin_success do
  save_session_votes
end
