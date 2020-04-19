# ImportManager coordinates the import of a CsvFile. It defines the conflict and error
# policy. It collects all errors and provides extra data like corrections for row fields.
class ImportManager
  attr_reader :conflict_strategy, :corrections, :status

  def initialize csv_file, conflict_strategy: :skip, corrections: {}, status: {}
    @csv_file = csv_file
    @conflict_strategy = conflict_strategy
    @corrections = corrections || {}
    @status = init_status status
  end

  def each_row row_indices=nil
    @csv_file.each_row self, row_indices do |row|
      yield row
    end
  end

  def import row_indices=nil, &block
    each_row(row_indices) { |row| row.import &block }
  end

  def validate row_indices=nil, &block
    each_row(row_indices) { |row| row.validate! &block }
  end

  def errors? row=nil
    errors(row).present?
  end

  def errors row=nil
    row ? status.item_errors(row) : status.errors
  end

  private

  def init_status status
    status.is_a?(Status) ? status : Status.new(status)
  end
end
