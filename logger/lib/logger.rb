

class Logger
  def self.with_logging method, opts, &block
    if ::Logger::Performance.enabled_method? method
      ::Logger::Performance.with_timer(method, opts) do
        block.call
      end
    else
      block.call
    end
  end
end

# class Card
#   def self.with_logging method, opts, &block
#     if Logger::Performance.enabled_method? method
#       Logger::Performance.with_timer(method, opts) do
#         block.call
#       end
#     else
#       block.call
#     end
#   end
# end

