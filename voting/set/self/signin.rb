event :save_session_votes_after_signin, :on=>:update, :after=>:signin do
  save_session_votes
end