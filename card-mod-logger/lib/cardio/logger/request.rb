require 'csv'

module Cardio
  class Logger
    class Request
      class << self
        def path
          path = Card.paths['request_log']&.first || File.dirname(Card.paths['log'].first)
          filename = "#{Date.today}_#{Rails.env}.csv"
          File.join path, filename
        end

        def write_log_entry controller
          env = controller.env
          return if env["REQUEST_URI"] =~ %r{^/files?/}

          controller.instance_eval do
            File.open(Request.path, "a") do |f|
              items = Request.log_items env, card, action_name, status
              f.write CSV.generate_line(items)
            end
          end
        end

        def log_items env, card, action_name, status
          params = Card::Env.params
          [
            (Card::Env.ajax? ? "YES" : "NO"),
            env["REMOTE_ADDR"],
            Card::Auth.current_id,
            card.name,
            action_name,
            (params[:view] || params.dig(:success, :view)),
            env["REQUEST_METHOD"],
            status,
            env["REQUEST_URI"],
            Time.now.to_s,
            env['HTTP_ACCEPT_LANGUAGE'].to_s.scan(/^[a-z]{2}/).first,
            env["HTTP_REFERER"]
          ]
        end
      end
    end
  end
end
