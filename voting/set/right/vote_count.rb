# session vote won't be saved to real vote count until user login
# users will see a different vote count as the vote from anonymous would be
# counted in rendering the vote count
def session_vote?
  # override with true to allow voting for users who are not logged in
  # and save votes in session
  false
end

def votee
  cardname.left
end

# The voted card ids will be stored in a pointer card. insert_before_id is used
# to add the id in front of another id.
# it may just affect the showing order of the the votes only.
# In wikirate, insert_before_id is used while a votable card is dragged and
# dropped in user's profile.
# it will insert the card to specific position in the pointer card which
# contains what users voted
def vote_up insert_before_id=false
  register_vote :up, insert_before_id
end

def vote_down insert_before_id=false
  register_vote :down, insert_before_id
end

def register_vote direction, insert
  if Auth.signed_in?
    register_account_vote direction, insert
  elsif session_vote?
    record_session_vote direction, insert
  end
end

def voted_other direction, append=nil
  other_dir = direction == :up ? :down : :up
  other_dir = "#{other_dir}#{append}".to_sym if append
  other_dir
end

def register_account_vote direction, insert
  return unless (action = case vote_status
                          when :no_vote                       then :add
                          when voted_other(direction, :voted) then :delete
                          end)
  Auth.as_bot { send "#{action}_account_vote", direction, insert }
end

def add_account_vote direction, insert
  vote_card = Auth.current.send "#{direction}votes_card"
  return unless update_vote_card_content vote_card, left.id, insert
  vote_card.save!
  update_votecount
end

def delete_account_vote direction, _insert
  vote_card = Auth.current.send "#{voted_other(direction)}votes_card"
  return unless vote_card.drop_id left.id
  vote_card.save!
  update_votecount
end

def record_session_vote direction, insert
  if left.send voted_other(direction, :voted_in_session?)
    Env.session[voted_other(direction, :_vote)].delete left.id
  else
    add_vote_to_session "#{direction}_vote".to_sym, left.id, insert
  end
end

def update_vote_card_content vote_card, votee_id, insert_before_id
  if insert_before_id
    vote_card.insert_id_before votee_id, insert_before_id
  else
    vote_card.add_id votee_id
  end
end

def add_vote_to_session vote_type, votee_id, insert_before_id
  Env.session[vote_type] ||= []
  Env.session[vote_type].delete(votee_id)
  if insert_before_id &&
     (index = Env.session[vote_type].index(insert_before_id))
    Env.session[vote_type].insert(index, votee_id)
  else
    Env.session[vote_type] << votee_id
  end
end

# FIXME: inefficient!
def force_up insert_before_id=false
  vote_up insert_before_id
  vote_up(insert_before_id) if vote_status != :upvoted
end

def force_down insert_before_id=false
  vote_down insert_before_id
  vote_down(insert_before_id) if vote_status != :downvoted
end

def force_neutral insert_before_id=false
  case vote_status
  when :downvoted
    vote_up insert_before_id
  when :upvoted
    vote_down insert_before_id
  end
end

def content
  return super if Auth.signed_in? || !session_vote?
  if session_votes? :up
    (standard_content.to_i + 1).to_s
  elsif session_votes? :down
    (standard_content.to_i - 1).to_s
  else
    super
  end
end

def session_votes? direction
  key = "#{direction}_vote".to_sym
  votes = Env.session[key]
  votes && votes.include?(left.id)
end

def direct_contribution_count
  left.upvote_count.to_i + left.downvote_count.to_i
end

def update_votecount
  Auth.as_bot do
    count = tally_votes(:up) - tally_votes(:down)
    self.content = count.to_s
    self.auto_content = true
  end
end

def tally_votes direction
  count = count_votes direction
  count_card = left.send "#{direction}vote_count_card"
  update_count_card count_card, count
  count
end

def update_count_card count_card, count
  count_card.auto_content = true
  count_card.content = count.to_s
  subcards.add count_card
end

def count_votes direction
  tag_id = Card.const_get "#{direction.to_s.capitalize}votesID"
  Card.search({ right_plus: [tag_id, { link_to: name.left }],
                return: "count" },
              "#{direction}votes linking to #{name.left}")
end

def vote_status
  left.vote_status
end

def can_vote?
  Auth.signed_in? || session_vote?
end

def vote_param
  Env.params["vote"]
end

event :vote, :prepare_to_validate, on: :update, when: :vote_param do
  if can_vote?
    send vote_method_from_params, successor_id_from_params
    abort :success if !Auth.signed_in? && session_vote?
  else
    redirect_to_vote_later
  end
end

def redirect_to_vote_later
  path_hash = { action: :update, vote: vote_param, success: "*previous" }
  uri = format.path path_hash
  Env.save_interrupted_action uri
  abort success: "REDIRECT: #{Card[:signin].name.url_key}"
end

VOTE_PARAM_TO_METHOD_MAP = {
  "up"            => :vote_up,
  "down"          => :vote_down,
  "force-up"      => :force_up,
  "force-down"    => :force_down,
  "force-neutral" => :force_neutral
}.freeze

def vote_method_from_params
  VOTE_PARAM_TO_METHOD_MAP[vote_param]
end

def successor_id_from_params
  successor_id = Env.params["insert-before"]
  successor_id && successor_id.to_i
end

format :html do
  view :missing do
    if card.new_card? && (l = card.left) && l.respond_to?(:vote_count)
      Auth.as_bot do
        card.update_votecount
        card.save!
      end
      render! @denied_view
    else
      super()
    end
  end

  view :new, :missing

  view :content do
    class_up "card-slot", "card-content nodblclick"
    wrap do
      [
        _render(:menu, {}, :hide),
        wrap_with(:div, class: "vote-up") { vote_up_link(:content) },
        render!(:core),
        wrap_with(:div, class: "vote-down") { vote_down_link(:content) }
      ]
    end
  end

  view :core do
    html_class = "vote-count"
    case card.vote_status
    when :upvoted then html_class += " current-user-up"
    when :downvoted then html_class += " current-user-down"
    end
    wrap_with :div, class: html_class do
      super()
    end
  end

  view :details do
    class_up "card-slot", "nodblclick"
    wrap do
      [
        vote_details(:up),
        _render_core,
        vote_details(:down)
      ]
    end
  end

  def vote_details direction
    wrap_with(:div, class: "vote-#{direction}") do
      [
        send("vote_#{direction}_link", :details),
        send("#{direction}_details")
      ]
    end
  end

  def vote_up_link success_view
    case card.left.vote_status
    when :upvoted
      disabled_vote_link :up, "You have already upvoted this."
    else
      vote_link '<i class="fa fa-chevron-up"></i>', "Vote up", :up, success_view
    end
  end

  def vote_down_link success_view
    case card.left.vote_status
    when :downvoted
      disabled_vote_link :down, "You have already downvoted this."
    else
      vote_link '<i class="fa fa-chevron-down"></i>', "Vote down", :down,
                success_view
    end
  end

  def disabled_vote_link up_or_down, message, extra={}
    html_class = "current-user-" + up_or_down.to_s
    html_class += " slotter disabled-vote-link vote-button"
    button_tag({ disabled: true,
                 class: html_class, type: "button",
                 title: message }.merge(extra)) do
      "<i class=\"fa fa-chevron-#{up_or_down} \"></i>"
    end
  end

  def vote_link text, title, up_or_down, view, extra={}
    link_to text, { path: vote_path(up_or_down, view),
                    class: "slotter vote-link vote-button",
                    title: title, remote: true, method: "post", rel: "nofollow"
                  }.merge(extra)
  end

  def vote_path up_or_down=nil, view="content"
    path_hash = { name: card.name, action: :update, view: view }
    path_hash[:vote] = up_or_down if up_or_down
    path path_hash
  end

  def up_details
    haml up_count: card.left.upvote_count do
      %(
%span.vote-details
  <i class="fa fa-users"></i>
  %span.vote-number
    = up_count
  Important
      )
    end
  end

  def down_details
    haml down_count: card.left.downvote_count do
      %(
%span.vote-details
  <i class="fa fa-users"></i>
  %span.vote-number
    = down_count
  Not important
      )
    end
  end
end
