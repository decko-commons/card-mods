class Card
  class ImportLog
    LogFile = Rails.root.join("log", "import.log")
    class << self
      attr_accessor :logger
      delegate :debug, :info, :warn, :error, :fatal, to: :logger
    end
  end
end
