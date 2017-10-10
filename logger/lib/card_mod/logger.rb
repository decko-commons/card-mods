
module CardMod
  class Logger
    require_dependency "card_mod/logger/performance"

    def self.with_logging method, opts, &block
      return block.call unless CardMod::Logger::Performance.enabled_method? method
      CardMod::Logger::Performance.with_timer(method, opts) do
        block.call
      end
    end
  end
end


