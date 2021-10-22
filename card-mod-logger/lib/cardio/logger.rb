
module Cardio
  class Logger
    def self.with_logging method, opts, &block
      return block.call unless Performance.enabled_method? method
      Performance.with_timer(method, opts) do
        block.call
      end
    end
  end
end
