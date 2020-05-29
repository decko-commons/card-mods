# ActImportManager puts all creates and update actions that are part of the import
# under one act of a import card
class Card
  class ActImportManager < ImportManager
    def initialize *args
      @act_card = args.shift
      super *args
    end
  end
end
