class Card
  # ImportManager coordinates an Car.
  # It defines the conflict strategy and corrections for item fields.
  class ImportManager
    OPTIONS = { conflict_strategy: :skip,
                corrections: nil,
                abort_on_error: false }.freeze

    OPTIONS.keys.map { |o| attr_accessor o }
    attr_reader :importer

    def initialize importer, options={}
      @importer = importer
      OPTIONS.each do |optname, default_value|
        self.send "#{optname}=", (options.key?(optname) ? options[optname] : default_value)
      end
    end

    def each_item item_indices=nil
      importer.each_input item_indices do |input_hash, index|
        Card::Cache.renew
        item_object = importer.item_class.new input_hash, import_manager: self
        yield index, item_object
      end
    end

    def import_transaction
      Card.transaction do
        Card::Cache.renew
        yield
      end
    end
  end
end
