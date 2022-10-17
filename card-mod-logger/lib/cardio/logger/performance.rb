module Cardio
  class Logger
    class Performance
      DEFAULT_CLASS = Card
      DEFAULT_METHOD_TYPE = :all
      DEFAULT_LOG_LEVEL = :info
      DEFAULT_METHOD_OPTIONS = {
        :title => :method_name,
        :message => 1,
        :details => 1..-1,
        :context => nil
      }

      SPECIAL_METHODS = [:search, :view, :event, :rule, :execute] # these methods have already a Decko.with_logging block
      # we don't have to monkey patch them, only turn the logging on with adding the symbol to the methods hash

      TAB_SIZE = 3
      cattr_reader :log, :category_log

      @@log = []
      @@category_log = CategoryLog.new
      @@context_entries = []
      @@active_entries = []
      @@current_level = 0

      class << self
        def default_methods_config
          [:execute, :rule, :fetch, :view]
#         {
#           # ActiveRecord => {
#           #   :instance => {
#           #     :save      => { :category => 'SQL'},
#           #     :take => { :category => 'SQL'},
#           #     :_create_record => { :category => 'SQL'},
#           #     :_update_record => { :category => 'SQL'}
#           #   },
#           #   :singleton=> {
#           #     :delete    => { :category => 'SQL'},
#           #     :find    => { :category => 'SQL'},
#           #     :update    => { :category => 'SQL'},
#           #     :create    => { :category => 'SQL'},
#           #     :where    => { :category => 'SQL'}
#           #   }
#           # },
#           Card => {
#             :instance => {
#               :rule_card => { :category => 'rule' }
#               # :'update!' => { :category => 'SQL'},
#               # :update    => { :category => 'SQL'},
#               # :save      => { :category => 'SQL'},
#               # :'save!'   => { :category => 'SQL'},
#               # :delete    => { :category => 'SQL'},
#               # :'delete!' => { :category => 'SQL'}
#             },
#             :singleton => {
#               :fetch => { :category => 'fetch' },
#               :view  => { :category => 'content'},
#               # :delete => { :category => 'SQL'},
#               # :find => { :category => 'SQL'},
#               # :update => { :category => 'SQL'},
#               # :create => { :category => 'SQL'},
#               :where   => { :category => 'SQL'},
#               :execute => { :category => 'SQL'}
# #              :take   => { :category => 'Take'}
#             }
#           },
#           # Card::Query => {
#           #   :instance => {
#           #     :run_sql => { :category => 'SQL'},
#           #
#           #   }
#           # }
#         }
        end

        def load_config args
          args = params_to_config args
          @details = args[:details] || false
          @max_depth = args[:max_depth] || false
          @min_time = args[:min_time] || false
          @log_level = args[:log_level] || DEFAULT_LOG_LEVEL
          @output = args[:output] || :text
          @output_card = args[:output_card] || '*all'
          @enabled_methods = ::Set.new
          if args[:methods] == :default
            args[:methods] = default_methods_config
          end
          prepare_methods_for_logging args[:methods] if args[:methods]
        end

        def start args = {}
          @@current_level = 0
          @@log = []
          @@context_entries = []
          @@active_entries = []
          @@first_entry = new_entry(args)
          @@category_log = CategoryLog.new args[:category]
        end

        def stop
          finish_all_context_entries
          if @@first_entry
            @@first_entry.save_duration
            finish_entry @@first_entry
          end
          print_log
        end

        def with_timer method, args, &block
          if args[:context]
            update_context args[:context]
          end

          timer = new_entry args.merge(:method => method)
          begin
            result = block.call
          ensure
            timer.save_duration
            finish_entry timer
            finish_context
          end
          result
        end

        def enable_method method_name
          @enabled_methods ||= ::Set.new
          @enabled_methods << method_name
        end

        def enabled_method? method_name
          @enabled_methods && @enabled_methods.include?(method_name)
        end

        private

        def update_context new_context
          # if the current context was created by an entry on the same level
          # then finish it if it's a different context
          if (current_context = @@context_entries.last) &&
            current_context.level + 1 == @@current_level && # the
            new_context != current_context.context
            finish_entry @@context_entries.pop
          end

          # start new context if it's different from the current context
          if @@context_entries.empty? || new_context != @@context_entries.last.context
            @@context_entries << new_entry(:title => 'process', :message => new_context, :context => new_context)
          end
        end

        def finish_context
          # finish all deeper nested contexts
          while @@context_entries.last && @@context_entries.last.level >= @@current_level
            finish_entry @@context_entries.pop
          end
          # we don't know whether the next entry will belong to the same context or will start a new one
          # so we save the time
          @@context_entries.last.save_duration if @@context_entries.last
        end

        def print_log
          if @output == :card && @output_card
            html_log = HtmlFormatter.new(self).output
            card = @output_card.fetch :performance_log, new: { type: :pointer }
            card.add_log_entry @@log.first.message, html_log
          elsif @output == :html
            HtmlFormatter.new(self).output
          else
            text_log = TextFormatter.new(self).output
            Rails.logger.send @log_level, text_log
          end
        end


        def new_entry args
          args.delete(:details) unless @details
          level = @@current_level

          last_entry = @@active_entries.last
          parent = parent_entry last_entry, level
          @@category_log.start args[:category] if args[:category]

          @@log << Entry.new(parent, level, args)
          @@current_level += 1
          @@active_entries << @@log.last

          @@log.last
        end

        def finish_entry entry
          if entry.category
            @@category_log.stop entry.category
          end
          if (@max_depth && entry.level > @max_depth) || (@min_time && entry.duration < @min_time)
            entry.delete
          end
          @@active_entries.pop
          @@current_level -= 1
        end

        def finish_all_context_entries
          while (entry = @@context_entries.pop) do
            entry.save_duration unless entry.duration
            finish_entry entry
          end
        end

        def prepare_methods_for_logging args
          classes = hashify_and_verify_keys(args, DEFAULT_CLASS) do |key|
            key.kind_of?(Class) || key.kind_of?(Module)
          end

          classes.each do |klass, method_types|
            klass.extend BigBrother # add watch methods

            method_types = hashify_and_verify_keys(method_types, DEFAULT_METHOD_TYPE) do |key|
              [:all, :instance, :singleton].include? key
            end

            method_types.each do |method_type, methods|
              methods = hashify_and_verify_keys methods
              methods.each do |method_name, options|
                klass.watch_method method_name, method_type, DEFAULT_METHOD_OPTIONS.merge(options)
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

        def params_to_config args
          args[:details] = args[:details] == 'true' ? true : false
          args[:max_depth] &&= args[:max_depth].to_i
          args[:min_time] &&= args[:min_time].to_i
          args[:output] &&= args[:output].to_sym
          standardize_methods_arg args
          args
        end

        private

        def parent_entry last_entry, level
          return unless last_entry

          last_entry.level == level ? last_entry.parent : last_entry
        end

        def standardize_methods_arg args
          case args[:methods]
          when String
            return unless args[:methods].match?(/^\[.+\]$/)
            args[:methods] = JSON.parse(args[:methods]).map(&:to_sym)
          when Array
            args[:methods].map!(&:to_sym)
          end
        end

        def hash_and_verify_with_default_key args, default_key, &block
          case args
          when Symbol
            { default_key => [args] }
          when Array
            { default_key => args }
          when Hash
            block_given? ? hash_and_verify_with_block(args, default_key, &block) : args
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
            args.inject({}) do |h, key|
              h[key] = {}
              h
            end
          else
            args
          end
        end
      end
    end
  end
end
