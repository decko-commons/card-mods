# ImportManager coordinates the import of a CsvFile. It defines the conflict and error
# policy. It collects all errors and provides extra data like corrections for row fields.
class ImportManager
  include Conflicts

  attr_reader :conflict_strategy, :corrections, :status

  def initialize csv_file, conflict_strategy: :skip, corrections: {}, status: {}
    @csv_file = csv_file
    @conflict_strategy = conflict_strategy

    @corrections = corrections
    @status = init_status status
    @imported_keys = ::Set.new
  end

  def init_status status
    status.is_a?(Status) ? status : Status.new(status)
  end

  def import row_indices=nil
    import_rows row_indices
  end

  def import_rows row_indices
    @csv_file.each_row self, row_indices do |row|
      row.execute_import
      yield row if block_given?
    end
  end

  def validate row_indices=nil
    @abort_on_error = false
    validate_rows row_indices
  end

  def validate_rows row_indices
    #row_count = row_indices ? row_indices.size : @csv_file.row_count
    @csv_file.each_row self, row_indices do |csv_row|
      csv_row.validate!
    end
  end

  def errors? row=nil
    row ? errors(row).present? : errors.present?
  end

  def errors row=nil
    row ? status.item_errors(row) : status.errors
  end
end
