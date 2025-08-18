
def google_analytics_keys
  @google_analytics_keys ||= Array.wrap(
    Card::Rule.global_setting(:google_analytics_key) || Card.config.google_analytics_key
  )
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
