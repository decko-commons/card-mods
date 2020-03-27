# ImportManager coordinates the import of a CsvFile. It defines the conflict and error
# policy. It collects all errors and provides extra data like corrections for row fields.
class ImportManager
  include StatusLog
  include Conflicts

  attr_reader :conflict_strategy, :corrections, :status

  def initialize csv_file, conflict_strategy: :skip, corrections: {}, status: {}
    @csv_file = csv_file
    @conflict_strategy = conflict_strategy
    # @extra_data = integerfy_keys(extra_data || {})
#
    # @extra_data[:all] ||= {}
    # init_import_status

    @corrections = corrections
    @status = ImportManager::Status.new status
    @imported_keys = ::Set.new
  end

  def import row_indices=nil
    import_rows row_indices
  end

  def import_rows row_indices
    # row_count = row_indices ? row_indices.size : @csv_file&.row_count
    # init_import_status row_count
    @csv_file.each_row self, row_indices, &:execute_import
  end

  # def extra_data index
  #   (@extra_data[:all] || {}).deep_merge(@extra_data[index] || {})
  # end

  def validate row_indices=nil
    @abort_on_error = false
    validate_rows row_indices
    status.recount
  end

  def validate_rows row_indices
    #row_count = row_indices ? row_indices.size : @csv_file.row_count
    @csv_file.each_row self, row_indices do |csv_row|
      csv_row.validate!
    end
  end

  def add_extra_data index, data
    @extra_data[index].deep_merge! data
  end

  # add the final import card
  def import_card card_args
    @current_row.name = card_args[:name]
    check_for_duplicates card_args[:name]
    add_card card_args
  end

  private

  # methods like row_imported, row_failed, etc. can be used to add additional logic
  def run_hook status
    row_finished @current_row if respond_to? :row_finished
    hook_name = "row_#{status}".to_sym
    send hook_name, @current_row if respond_to? hook_name
  end

  def integerfy_keys hash
    hash.transform_keys { |key| key == :all ? :all : key.to_s.to_i }
  end
end
