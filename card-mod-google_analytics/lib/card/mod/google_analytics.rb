Cardio::Railtie.config.tap do |config|
  config.google_analytics_key = nil
  config.google_analytics_api_tracker_measurement_id = nil
  config.google_analytics_api_tracker_api_secret = nil
  config.google_analytics_api_tracker_salt = nil
  config.google_analytics_api_tracker_debug = false

  config.track_api_requests = false
end
