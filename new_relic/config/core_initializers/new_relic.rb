
ActiveSupport.on_load :card do
  require 'new_relic/agent/method_tracer'

  class Card
    include ::NewRelic::Agent::MethodTracer

    class << self
      add_method_tracer :fetch, "Custom/fetch"
    end

    module Set
      class Event
        def define_simple_method
          @set_module.class_exec(self) do |event|
            include ::NewRelic::Agent::MethodTracer
            define_method event.simple_method_name, &event.block
            add_method_tracer event.simple_method_name, "Custom/Event/#{event.name}"
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

      module AbstractFormat
        include ::NewRelic::Agent::MethodTracer
        def define_standard_view_method view, &block
          super
          view_method = Card::Set::Format.view_method_name view
          add_method_tracer view_method, "Custom/View/#{view}"
        end
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

