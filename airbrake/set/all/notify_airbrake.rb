event :notify_airbrake, after: :notable_exception_raised do
  return unless Airbrake.configuration.api_key && Env[:controller]
  Env[:controller].send :notify_airbrake, Card::Error.current
end
