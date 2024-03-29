class Card
  # ImportManager coordinates imports.
  # It defines the conflict strategy and mapping for item fields.
  class ImportManager
    OPTIONS = { conflict_strategy: :skip, mapping: nil, abort_on_error: false }.freeze

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
        item_object = importer.item_class.new input_hash, import_manager: self
        yield index, item_object
      end
    end
  end
end
