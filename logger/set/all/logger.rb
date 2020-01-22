require_dependency "card_mod/logger"
require_dependency "card_mod/logger/performance"

# Not the pefect place. Ideally this should happen after loader.rb#load_mods
# so that it's possible to log any method.
# With this approach we can only log methods of mods that get loaded before
# this mod.
if Cardio.config.performance_logger
  CardMod::Logger::Performance.load_config Card.config.performance_logger
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
  CardMod::Logger::Request.write_log_entry Env[:controller]
end

def request_logger?
  Card.config.request_logger
end

def start_performance_logger
  if Env.params[:performance_log]
    CardMod::Logger::Performance.load_config Env.params[:performance_log]
  end
  if (request = Env[:controller]&.request)
    method = request.env["REQUEST_METHOD"]
    path   = request.env["PATH_INFO"]
  else
    method = "no request"
    path = "no path"
  end
  CardMod::Logger::Performance.start method: method, message: path, category: "format"
end

def stop_performance_logger
  CardMod::Logger::Performance.stop
  return unless Env.params[:perfomance_log]
  CardMod::Logger::Performance.load_config(Card.config.performance_logger || {})
end

def performance_log?
  Env.params[:performance_log] || Card.config.performance_logger
end


