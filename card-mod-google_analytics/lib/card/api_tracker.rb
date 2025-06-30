require "faraday"

class Card
  # supports tracking api requests with Google Analytics measurement id
  class ApiTracker
    attr_reader :event

    def initialize event
      @event = event
    end

    def body
      {
        "client_id": client_id,
        "events": [
          {
            "name": event_name,
            "params": event_params
          }
        ]
      }
    end

    def client_id
      Digest::SHA256.hexdigest(Auth.current_id.to_s + self.class.config(:salt))
    end

    def payload
      @event.payload
    end

    def event_name
      action = payload[:action]
      "api_data_#{action == 'read' ? 'fetch' : action}"
    end

    def event_params
      {
        status_code: payload[:status],
        format: payload[:format],
        path: payload[:path],
        # query_params: request.query_string,
        client: payload[:request].user_agent,
        response_time: event.duration,
        engagement_time_msec: 1
      }.merge card_params, format_params
    end

    def card
      Env.controller.card
    end

    def format
      Env.controller.format
    end

    def card_params
      card.api_tracker_event_params
    end

    def format_params
      format.api_tracker_event_params
    end

    class << self
      def track! event
        tracker = new event
        response = connection.post(path) do |req|
          rbody = tracker.body
          req.body = rbody.to_json
          puts JSON.pretty_generate rbody if debug?
        end
        Rails.logger.debug response.body if debug?
      end

      def track event
        track! event if track?
      end

      def config field
        Cardio.config.send "google_analytics_api_tracker_#{field}"
      end

      private

      def track?
        Cardio.config.track_api_requests &&
          Auth.api_request? &&
          Auth.current.account&.api_tracker == "yes"
      end

      def debug?
        config :debug
      end

      def connection
        @connection ||= Faraday.new(
          url: "https://www.google-analytics.com",
          params: {
            measurement_id: config(:measurement_id),
            api_secret: config(:api_secret)
          },
          headers: { "Content-Type" => "application/json" }
        ) do |faraday|
          faraday.response :logger if debug?
        end
      end

      def path
        @path ||= debug? ? "debug/mp/collect" : "mp/collect"
      end
    end
  end
end
