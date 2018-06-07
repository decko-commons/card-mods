
ActiveSupport.on_load :card do
  require 'new_relic/agent/method_tracer'

  class Card
    include ::NewRelic::Agent::MethodTracer

    module Set
      module Event
        extend ::NewRelic::Agent::MethodTracer
        def define_simple_method event, method_name, &method
          class_eval do
            #include
            define_method method_name, &method
            add_method_tracer method_name, "event/#{event}"
          end
        end
      end
    end

    class Format
      module Render
        include ::NewRelic::Agent::MethodTracer
        add_method_tracer! :render!
      end
    end
  end
end

