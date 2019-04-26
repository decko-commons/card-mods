module ClassMethods
  include ::NewRelic::Agent::MethodTracer
  add_method_tracer :fetch, "Custom/fetch"
end