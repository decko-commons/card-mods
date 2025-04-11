require "faraday"

event :track_page, before: :show_page, when: :track_page_from_server? do
  # track_page!
  puts tracker_options
end

def track_page!
  tracker.pageview tracker_options
end

def google_analytics_keys
  @google_analytics_keys ||= Array.wrap(
    Card::Rule.global_setting(:google_analytics_key) || Card.config.google_analytics_key
  )
end

def tracker
  tracker_key && ::Staccato.tracker(tracker_key) # , nil, ssl: true
end

# can have separate keys for web and API
def tracker_key
  Card.config.google_analytics_tracker_key || google_analytics_keys.first
end

def tracker_event_parameters
  r = Env.controller.request
  {
    cardtype: type_name,
    cardtype_id: type_id,
    card_id: id,
    card_name: name,
    limit: Env.params[:limit],
    api_key: Auth.api_keys.first,
    query_string: r.query_string,
    # status_code: "XXXX",
    # error_message:,
    # client:,
    # response_time:,
  }
end

# for override
def track_page_from_server?
  false
end

format :html do
  basket[:head_views].unshift :google_analytics_snippets

  delegate :google_analytics_keys, to: :card

  def body_tag klasses=""
    super { "#{render(:google_analytics_noscript)}\n\n#{yield}" }
  end

  view :google_analytics_snippets, unknown: true, perms: :none do
    haml :google_analytics_snippets if google_analytics_keys.present?
  end

  view :google_analytics_noscript, unknown: true, perms: :none do
    haml :google_analytics_noscript if google_tag_manager_keys.present?
  end

  def google_tag_manager_keys
    @google_tag_manager_keys ||= google_analytics_keys.find_all do |key|
      key.match?(/^GTM-/)
    end
  end

  def google_analytics_snippet_vars
    { anonymizeIp: true }
  end
end
