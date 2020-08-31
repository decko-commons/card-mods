class Card
  # ImportManager coordinates an Car.
  # It defines the conflict strategy and corrections for item fields.
  class ImportManager
    OPTIONS = { conflict_strategy: :skip,
                corrections: nil,
                abort_on_error: false }.freeze

    OPTIONS.keys.map { |o| attr_accessor o }

    def initialize importer, options={}
      @importer = importer
      OPTIONS.each do |optname, default_value|
        self.send "#{optname}=", (options.key?(optname) ? options[optname] : default_value)
      end
    end

    def each_item item_indices=nil
      @importer.each_item self, item_indices do |index, item|
        [index, yield(item)]
      end
    end

    def import item_indices=nil
      each_item(item_indices) do |index, item|
        [index, yield(item.import)]
        yield item.import
      end
    end
  end
end
