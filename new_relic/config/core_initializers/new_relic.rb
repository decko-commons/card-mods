
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
            add_method_tracer method_name, "Custom/Event/#{event}"
          end
        end
      end
    end

    class Format
      module Render
        include ::NewRelic::Agent::MethodTracer
        add_method_tracer :render!, "Custom/Format/render!"
        add_method_tracer :final_render, "Custom/Format/final_render"
      end
    end

    class Content
      class Parser
        class << self
          include ::NewRelic::Agent::MethodTracer
          add_method_tracer :parse, "Custom/Content/parse"
        end
      end
    end

    module Query
      class << self
        include ::NewRelic::Agent::MethodTracer
        add_method_tracer :new, "Custom/Query/new"
      end
    end

    class View
      include ::NewRelic::Agent::MethodTracer
      add_method_tracer :initialize, "Custom/View/initialize"
      add_method_tracer :process, "Custom/View/process"
    end
  end
end

