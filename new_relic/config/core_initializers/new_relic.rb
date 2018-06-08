
ActiveSupport.on_load :card do
  require 'new_relic/agent/method_tracer'

  class Card
    include ::NewRelic::Agent::MethodTracer

    module Set
      module Event
        def define_simple_method event, method_name, &method
          class_eval do
            define_method method_name, &method
            Card.add_method_tracer method_name, "event/#{event}"
          end
        end
      end
    end

    class Format
      module Render
        include ::NewRelic::Agent::MethodTracer
        add_method_tracer :render!, "Format/render"
      end
    end

    class Content
      class Parser
        include ::NewRelic::Agent::MethodTracer
        add_method_tracer :parse, "Content/parse"
      end
    end

    module Query
      include ::NewRelic::Agent::MethodTracer
      add_method_tracer :new, "Query/new"
    end

    class View
      include ::NewRelic::Agent::MethodTracer
      add_method_tracer :initialize, "View/initialize"
      add_method_tracer :process, "View/process"
    end
  end
end

