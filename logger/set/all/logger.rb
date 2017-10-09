require_dependency "card/logger"
require_dependency "card/logger/performance"

# Not the pefect place. Ideally this should happen after loader.rb#load_mods
# so that it's possible to log any method.
# With this approach we can only log methods of mods that get loaded before
# this mod.
if Card.config.performance_logger
  Card::Logger::Performance.load_config Card.config.performance_logger
end

event :start_performance_logger_on_change, before: :act,
                                           when: :performance_log? do
  start_performance_logger
  @handle_logger = true
end

event :stop_performance_logger_on_change, after: :act,
                                          when: :performance_log? do
  stop_performance_logger
  @handle_logger = false
end

event :start_performance_logger_on_read, before: :show_page, on: :read,
                                         when: :performance_log?  do
  start_performance_logger unless @handle_logger
end

event :stop_performance_logger_on_read, after: :show_page, on: :read,
                                        when: :performance_log? do
  stop_performance_logger unless @handle_logger
end

event :request_logger, after: :show_page, when: :request_logger? do
  Card::Logger::Request.write_log_entry Env[:controller]
end

def request_logger?
  Card.config.request_logger
end

def start_performance_logger
  if Env.params[:performance_log]
    Card::Logger::Performance.load_config Env.params[:performance_log]
  end
  if (request = Env[:controller]&.request)
    method = request.env["REQUEST_METHOD"]
    path   = request.env["PATH_INFO"]
  else
    method = "no request"
    path = "no path"
  end
  Card::Logger::Performance.start method: method, message: path, category: "format"
end

def stop_performance_logger
  Card::Logger::Performance.stop
  return unless Env.params[:perfomance_log]
  Card::Logger::Performance.load_config(Card.config.performance_logger || {})
end

def performance_log?
  Env.params[:performance_log] || Card.config.performance_logger
end

class ::Card
  class Query
    alias original_run run
    def run
      Card::Logger.with_logging :search, message: @statement, details: sql do
        original_run
      end
    end
  end

  alias original_run_callbacks run_callbacks
  def run_callbacks event, &block
    Card::Logger.with_logging :event, message: event, context: self.name do
      original_run_callbacks event, &block
    end
  end

  module Set
    module All::Rules
      alias original_rule_card rule_card
      def rule_card setting_code, options={}
        Card::Logger.with_logging :rule, message: setting_code, category: "rule",
                                     context: name, details: options  do
          original_rule_card setting_code, options
        end
      end
    end
  end

  class View
    alias original_fetch fetch
    def fetch &block
      Card::Logger.with_logging(
        :view, message: ok_view, context: format.card.name,
               details: live_options, category: "content"
      ) do
        original_fetch(&block)
      end
    end
  end
end

module ::ActiveRecord::ConnectionAdapters
  class AbstractMysqlAdapter
    unless method_defined? :original_execute
      alias original_execute execute
      def execute sql, name=nil
        Card::Logger.with_logging :execute,
                              message: "SQL", category: "SQL", details: sql do
          original_execute sql, name
        end
      end
    end
  end
end
