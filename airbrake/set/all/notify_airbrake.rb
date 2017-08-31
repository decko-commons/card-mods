event :notify_airbrake, after: :notable_exception_raised do
  return unless Airbrake.configured? && Env[:controller]
  Env[:controller].send :notify_airbrake, Card::Error.current
end
