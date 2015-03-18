def save_session_votes
  [:up_vote, :down_vote].each do |vote_type| 
    if Env.session[vote_type]
      Env.session[vote_type].each do |votee_id|
        if (votee = Card.find(votee_id))
          update_vote votee, vote_type
        end
      end
      Env.session.delete(vote_type)
    end
  end
end


def update_vote votee, vote_type
  vote_card = votee.vote_count_card
  case vote_type
  when :up_vote
    vote_card.force_up
  when :down_vote
    vote_card.force_down
  end
  vote_card.save!
end

format :html do
  
  view :titled_with_voting, :tags=>:comment do |args|
    wrap args do   
      [
        subformat( card.vote_count_card ).render_content,
        _render_header( args.reverse_merge :optional_menu=>:hide ),
        wrap_body( :content=>true ) { _render_core args },
        optional_render( :comment_box, args )
      ]
    end
  end
  
  view :header_with_voting do |args|
    render_haml( :args=>args ) do
      %{
.header-with-vote
  .header-vote
    = subformat( card.vote_count_card ).render_details
  .header-title
    = render_header(args)
    .creator-credit
      = process_content "{{_self | structure:creator credit}}"
.clear-line
      }
    end
  end
end
