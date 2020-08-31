class Card
  # ImportManager coordinates the import of a Card::ImportCsv. It defines the conflict and error
  # policy. It collects all errors and provides extra data like corrections for item fields.
  class ImportManager
    attr_reader :conflict_strategy, :corrections, :status

    def initialize csv_file, conflict_strategy: :skip, corrections: nil
      @csv_file = csv_file
      @conflict_strategy = conflict_strategy
      @corrections = corrections # import map
    end

    def each_item item_indices=nil
      @csv_file.each_row self, item_indices do |item|
        yield item
      end
    end

    def import item_indices=nil
      each_item(item_indices) do |item|
        yield item.import
      end
    end

    def validate item_indices=nil
      each_item(item_indices) do |item|
        yield item.validate!
      end
    end
  end
end
