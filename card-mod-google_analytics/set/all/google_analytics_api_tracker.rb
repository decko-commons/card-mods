require "faraday"

event :track_api_request, after: :show_page, when: :track_api_request? do
  track_api_request!
end
# for override
def track_api_request?
  Cardio.config.track_api_requests && Auth.api_request?
end

def track_api_request!
  # uri = URI("https://www.google-analytics.com/mp/collect")
  # params = {
  #   measurement_id: Cardio.config.google_analytics_api_tracker_measurement_id,
  #   api_secret: Cardio.config.google_analytics_api_tracker_api_secret
  # }
  # uri.query = URI.encode_www_form(params)
  #
  # res = Net::HTTP.post_form uri,
  #                           body:

  response = api_tracker_connection.post(api_tracker_path) do |req|
    req.body = api_tracker_body.to_json
    # puts req.body
  end
  Rails.logger.debug response.body if Cardio.config.google_analytics_api_tracker_debug
end

private

def api_tracker_client_id
  Digest::SHA256.hexdigest(Auth.current_id.to_s +
                           Cardio.config.google_analytics_api_tracker_salt)
end

def api_tracker_connection
  @api_tracker_connection ||= Faraday.new(
    url: "https://www.google-analytics.com",
    params: {
      measurement_id: Cardio.config.google_analytics_api_tracker_measurement_id,
      api_secret: Cardio.config.google_analytics_api_tracker_api_secret
    },
    headers: { "Content-Type" => "application/json" }
  ) do |faraday|
    faraday.response :logger
  end
end

def api_tracker_path
  if Cardio.config.google_analytics_api_tracker_debug
    "debug/mp/collect"
  else
    "mp/collect"
  end
end

def api_tracker_body
  {
    "client_id": api_tracker_client_id,
    "events": [
      {
        "name": "api_data_fetch",
        "params": api_tracker_event_params
      }
    ]
  }
end

def api_tracker_status_code
  Env.controller.format.error_status || 200
end

def api_tracker_result_count
  results = Env.controller.format.instance_variable_get("@search_with_params")
  results.present? ? results.count : ""
end

def api_tracker_error_message
  Env.controller.card.format(:text).error_messages.join "; "
end

def api_tracker_event_params
  r = Env.controller.request

  {
    cardtype: type_name,
    cardtype_id: type_id,
    card_id: id,
    card_name: name,
    status_code: api_tracker_status_code,
    result_count: api_tracker_result_count,
    error_message: api_tracker_error_message,
    query_params: r.query_string,
    client: r.user_agent,
    engagement_time_msec: 1
  }
end
