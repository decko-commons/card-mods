
ActiveSupport.on_load :card do
  require 'new_relic/agent/method_tracer'

  class Card
    include ::NewRelic::Agent::MethodTracer

    module Set
      module Event
        def define_simple_method event, method_name, &method
          class_eval do
            include ::NewRelic::Agent::MethodTracer
            define_method method_name, &method
            add_method_tracer method_name, "event/#{event}"
          end
        end
      end
    end
  end
end

