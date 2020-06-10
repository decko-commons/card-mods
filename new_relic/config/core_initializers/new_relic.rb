  
ActiveSupport.on_load :card do
  require 'new_relic/agent/method_tracer'

  class Card
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

      module Format
        # module AbstractFormat::ViewDefinition
        #   include ::NewRelic::Agent::MethodTracer
        #   def define_standard_view_method view, &block
        #     views[self][view] = block
        #     traced_method_name = Card::Set::Format.view_method_name(view)
        #     true_method_name = "true_#{traced_method_name}"
        #     define_method true_method_name, &block
        #     define_method(traced_method_name) { send true_method_name }
        #     add_method_tracer traced_method_name, "Custom/View/#{view}"
        #   end
        # end

        module HamlPaths
          include ::NewRelic::Agent::MethodTracer
          add_method_tracer :haml_to_html, "Custom/Format/haml_to_html"
        end
      end
    end

    class Format
      module Render
        include ::NewRelic::Agent::MethodTracer
        # add_method_tracer :render!, "Custom/Format/render!"
        add_method_tracer :final_render, "Custom/Format/final_render"
        # add_method_tracer :stub_render, "Custom/Format/stub_render"
      end
    end

    class Content
      # class Parser
      #   class << self
      #     include ::NewRelic::Agent::MethodTracer
      #     add_method_tracer :parse, "Custom/Content/parse"
      #   end
      # end
    end

    module Query
      class << self
        include ::NewRelic::Agent::MethodTracer
        add_method_tracer :new, "Custom/Query/new"
      end
    end

    class View
      include ::NewRelic::Agent::MethodTracer
      # add_method_tracer :initialize, "Custom/Voo/initialize"
      add_method_tracer :process, "Custom/Voo/process"
      add_method_tracer :ok_view, "Custom/Voo/ok_view"
      module Permission
        include ::NewRelic::Agent::MethodTracer
        add_method_tracer :alter_unknown, "Custom/Voo/alter_unknown"
        add_method_tracer :denial, "Custom/Voo/denial"
      end

      module Cache
        include ::NewRelic::Agent::MethodTracer
        add_method_tracer :cache_render, "Custom/Voo/cache_render"
        add_method_tracer :cache_fetch, "Custom/Voo/cache_fetch"
      end
    end

    class Fetch
      include ::NewRelic::Agent::MethodTracer
      add_method_tracer :initialize, "Custom/Fetch/initialize"
      add_method_tracer :retrieve_or_new, "Custom/Fetch/retrieve_or_new"
      add_method_tracer :retrieve_existing, "Custom/Fetch/retrieve_existing"
      add_method_tracer :update_cache, "Custom/Fetch/update_cache"
      add_method_tracer :results, "Custom/Fetch/results"
    end
  end
end

