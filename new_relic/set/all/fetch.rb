module ClassMethods
  include ::NewRelic::Agent::MethodTracer
  add_method_tracer :set_patterns, "Custom/Card/set_patterns"
end