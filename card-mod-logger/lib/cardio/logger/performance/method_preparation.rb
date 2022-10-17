module Cardio
  class Logger
    class Performance
      # methods for preparing methods to have their performance watched
      module MethodPreparation
        private

        def prepare_methods_for_logging args
          classes = prepare_keys(args, DEFAULT_CLASS) do |key|
            key.is_a?(Class) || key.is_a?(Module)
          end

          classes.each do |klass, method_types|
            klass.extend BigBrother # add watch methods

            method_types = prepare_keys(method_types, DEFAULT_METHOD_TYPE) do |key|
              %i[all instance singleton].include? key
            end

            method_types.each do |method_type, methods|
              prepare_keys(methods).each do |method_name, options|
                klass.watch_method method_name, method_type,
                                   DEFAULT_METHOD_OPTIONS.merge(options)
              end
            end
          end
        end

        def prepare_keys args, default_key=nil, &block
          if default_key
            prepare_with_default_key args, default_key, &block
          else
            prepare_without_default_key args
          end
        end

        def prepare_with_default_key args, default_key, &block
          case args
          when Symbol
            { default_key => [args] }
          when Array
            { default_key => args }
          when Hash
            prepare_with_block args, default_key, &block if block_given?
            args
          end
        end

        def prepare_with_block args, default_key
          args.keys.select { |key| !yield(key) }.each do |key|
            args[default_key] = { key => args[key] }
            args.delete key
          end
        end

        def prepare_without_default_key args
          case args
          when Symbol
            { args => {} }
          when Array
            args.each_with_object({}) { |key, hash| hash[key] = {} }
          else
            args
          end
        end
      end
    end
  end
end
