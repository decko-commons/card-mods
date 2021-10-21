require "card_mod/logger"

class Card
  module Query
    class CardQuery
      alias_method :original_run, :run
      def run
        CardMod::Logger.with_logging :search, message: @statement, details: sql do
          original_run
        end
      end
    end
  end

  alias original_run_callbacks run_callbacks
  def run_callbacks event, &block
    CardMod::Logger.with_logging :event, message: event, context: self.name do
      original_run_callbacks event, &block
    end
  end

  module Card::Rule::All
    alias original_rule_card rule_card
    def rule_card setting_code, options={}
      CardMod::Logger.with_logging :rule, message: setting_code, category: "rule",
                                   context: name, details: options  do
        original_rule_card setting_code, options
      end
    end
  end

  class View
    alias original_fetch fetch
    def fetch &block
      CardMod::Logger.with_logging(
        :view, message: ok_view, context: format.card.name,
               details: live_options, category: "content"
      ) do
        original_fetch(&block)
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter
      unless method_defined? :original_execute
        alias original_execute execute
        def execute sql, name=nil
            # CardMod::Logger.with_logging :execute,
            #                        message: "SQL", category: "SQL", details: sql do
            original_execute sql, name
            # end
        end
      end
    end
  end
end
