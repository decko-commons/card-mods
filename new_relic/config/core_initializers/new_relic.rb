
ActiveSupport.on_load :card do
  class Card
    module Set
      module Event
        include ::NewRelic::Agent::MethodTracer

        def define_final_method method_name, &method
          class_eval do
            define_method method_name, &method
            add_method_tracer method_name, 'event/#{event}'
          end
        end
      end
    end
  end
end
