class Card
  class ImportLog
    LOG_FILE = Cardio.paths["log"].existent.first&.sub(/\.log$/, "-import.log")
    
    class << self
      attr_accessor :logger
      delegate :debug, :info, :warn, :error, :fatal, to: :logger
    end
  end
end
