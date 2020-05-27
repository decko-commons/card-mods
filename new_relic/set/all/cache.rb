module ClassMethods
  include ::NewRelic::Agent::MethodTracer
  add_method_tracer :write_to_cache, "Custom/Card/write_to_cache"
end