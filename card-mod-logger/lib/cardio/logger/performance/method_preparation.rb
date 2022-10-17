module Cardio
  class Logger
    class Performance
      module MethodPreparation
        private

        def prepare_methods_for_logging args
          classes = hashify_and_verify_keys(args, DEFAULT_CLASS) do |key|
            key.kind_of?(Class) || key.kind_of?(Module)
          end

          classes.each do |klass, method_types|
            klass.extend BigBrother # add watch methods

            method_types = hashify_and_verify_keys(method_types,
                                                   DEFAULT_METHOD_TYPE) do |key|
              [:all, :instance, :singleton].include? key
            end

            method_types.each do |method_type, methods|
              methods = hashify_and_verify_keys methods
              methods.each do |method_name, options|
                klass.watch_method method_name, method_type,
                                   DEFAULT_METHOD_OPTIONS.merge(options)
              end
            end
          end
        end

        def hashify_and_verify_keys args, default_key = nil, &block
          if default_key
            hash_and_verify_with_default_key args, default_key, &block
          else
            hash_and_verify_without_default_key args
          end
        end

        def hash_and_verify_with_default_key args, default_key, &block
          case args
          when Symbol
            { default_key => [args] }
          when Array
            { default_key => args }
          when Hash
            hash_and_verify_with_block args, default_key, &block if block_given?
            args
          end
        end

        def hash_and_verify_with_block args, default_key
          args.keys.select {|key| !(yield(key))}.each do |key|
            args[default_key] = { key => args[key] }
            args.delete key
          end
        end

        def hash_and_verify_without_default_key args
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
