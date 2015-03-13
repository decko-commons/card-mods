def session_vote?
  # override with true to allow voting for users who are not logged in 
  # and save votes in session
  false
end
  
def downvoted_in_session?
  Env.session[:down_vote] && Env.session[:down_vote].include?(votee)
end
def upvoted_in_session?
  Env.session[:up_vote] && Env.session[:up_vote].include?(votee)
end

def votee
  cardname.left
end

def vote_up
  if Auth.signed_in?
    Auth.as_bot do
      case vote_status
      when '?'
        uv_card = Auth.current.upvotes_card
        if uv_card.add_id left.id
          uv_card.save!
          update_votecount
        end
      when '-'
        dv_card = Auth.current.downvotes_card
        if dv_card.drop_id left.id
          dv_card.save!
          update_votecount
        end
      end
    end
  elsif session_vote?
    if downvoted_in_session?
      Env.session[:down_vote].delete votee
    else
      Env.session[:up_vote] ||= []
      Env.session[:up_vote] << votee
    end
  end
end

def vote_down
  if Auth.signed_in?
    Auth.as_bot do
      case vote_status
      when '?'
        dv_card = Auth.current.downvotes_card
        if dv_card.add_id left.id
          dv_card.save!
          update_votecount
        end
      when '+'
        uv_card = Auth.current.upvotes_card
        if uv_card.drop_id left.id
          uv_card.save!
          update_votecount
        end
      end
    end
  elsif session_vote?    
    if upvoted_in_session?
      Env.session[:up_vote].delete votee
    else
      Env.session[:down_vote] ||= []
      Env.session[:down_vote] << votee
    end
  end
end
    
def force_up
  vote_up
  vote_up if vote_status != '+'
end

def force_down
  vote_down
  vote_down if vote_status != '-'
end

def force_neutral
  case vote_status
  when '-'
    vote_up
  when '+'
    vote_down
  end
end


def raw_content
  if !Auth.signed_in? && session_vote?    
    if Env.session[:up_vote] && Env.session[:up_vote].include?(cardname.left)
      return (content.to_i + 1).to_s
    elsif Env.session[:down_vote] && Env.session[:down_vote].include?(cardname.left)
      return (content.to_i - 1).to_s
    end
  end
  super
end

def direct_contribution_count
  return left.upvote_count.to_i + left.downvote_count.to_i
end

def update_votecount
  up_count   = Auth.as_bot { Card.search( :right_plus=>[{:codename=>'upvotes'  },:link_to=>left.name], :return=>'count' ) }
  down_count = Auth.as_bot { Card.search( :right_plus=>[{:codename=>'downvotes'},:link_to=>left.name], :return=>'count' ) }

  uvc = left.upvote_count_card
  uvc.auto_content = true
  subcards[uvc.name] = up_count.to_s

  dvc = left.downvote_count_card
  dvc.auto_content = true
  subcards[dvc.name] = down_count.to_s

  self.content = (up_count - down_count).to_s
  self.auto_content = true
end

def vote_status
  if Auth.signed_in?
    if Auth.current.upvotes_card.include_item? "~#{left.id}"
      '+'
    elsif Auth.current.downvotes_card.include_item? "~#{left.id}"
      '-'
    else
      '?'
    end
  elsif session_vote?
    if upvoted_in_session?
      '+'
    elsif downvoted_in_session?
      '-'
    else
      '?'
    end
  else
    '#'
  end
end

event :vote, :before=>:approve, :on=>:update, :when=>proc{ |c| Env.params['vote'] } do
  if Auth.signed_in? || session_vote?
    case Env.params['vote']
    when 'up' then vote_up
    when 'down' then vote_down
    when 'force-up' then force_up
    when 'force-down' then force_down
    when 'force-neutral' then force_neutral
    end
  else
    path_hash = {:card=>self, :action=>:update,
                 :success=>{:id=>left.name}, :vote=>Env.params['vote'] }
    self.format.save_interrupted_action path_hash
    abort :success => "REDIRECT: #{Card[:signin].cardname.url_key}"
  end
end



format :html do
  view :missing  do |args|
    if card.new_card? && (l=card.left) && l.respond_to?( :vote_count )
      Auth.as_bot do
        card.update_votecount
        card.save!
      end
      render(args[:denied_view], args)
    else
      super(args)
    end
  end

  view :new, :missing

  view :content do |args|
    wrap args.merge(:slot_class=>'card-content nodblclick') do
      [
        _optional_render( :menu, args, :hide ),
        wrap_with(:div, :class=>'vote-up') { vote_up_link(:content) },
        _render_core( args ),
        wrap_with(:div, :class=>'vote-down') {vote_down_link(:content) }
      ]
    end
  end

  view :core do |args|
    wrap_with :div, :class=>'vote-count' do
      super(args)
    end
  end

  view :details do |args |
    wrap args.merge(:slot_class=>'nodblclick') do
      [
        wrap_with(:div, :class=>'vote-up') do
          [
            vote_up_link(:details),
            up_details
          ]
        end,
        _render_core( args ),
        wrap_with(:div, :class=>'vote-down') do
          [
            vote_down_link(:details),
            down_details
          ]
        end
      ]
    end
  end
  
  def vote_up_link success_view
    link = case card.vote_status
    when '+'
      disabled_vote_link :up, "You have already upvoted this claim."
    else
      vote_link '<i class="fa fa-angle-up "></i>', "Vote up", :up, success_view
    end
  end

  def vote_down_link success_view
    link = case card.vote_status
    when '-'
      disabled_vote_link :down, "You have already downvoted this claim."
    else
      vote_link '<i class="fa fa-angle-down "></i>', "Vote down", :down, success_view
    end
  end

  def disabled_vote_link up_or_down, message, extra={}
    button_tag({:disabled=>true,
        :class=>"slotter disabled-vote-link vote-button", :type=>'button', :title=>message}.merge(extra)) do
      "<i class=\"fa fa-angle-#{up_or_down} \"></i>"
    end
  end

  def vote_link text, title, up_or_down, view, extra={}
    button_tag({:href=>vote_path(up_or_down, view),
        :class=>"slotter vote-link vote-button", :type=>'button', :title=>title, :remote=>true, :method=>'post'}.merge(extra)) do
      text
    end
  end
  
  def vote_path up_or_down=nil, view='content'
    path_hash = {:card=>card, :action=>:update, :view=>view}
    path_hash[:vote] = up_or_down if up_or_down
    path path_hash
  end
  
  def up_details
    render_haml :up_count=>card.left.upvote_count do %{
%span.vote-details
  <i class="fa fa-users"></i>
  %span.vote-number
    = up_count
  Important
      }
    end
  end

  def down_details
    render_haml :down_count=>card.left.downvote_count do %{
%span.vote-details
  <i class="fa fa-users"></i>
  %span.vote-number
    = down_count
  Not important
      }
    end
  end
end
