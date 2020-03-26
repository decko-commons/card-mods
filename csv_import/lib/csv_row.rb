# Inherit from CsvRow to describe and process a csv row.
# CsvFile creates an instance of CsvRow for every row and calls #execute_import on it
class CsvRow
  include ::Card::Model::SaveHelper
  include Normalizer

  @columns = {}

  # Use column names as keys and method names as values to define normalization
  # and validation methods.
  # The normalization methods get the original field value as
  # argument. The validation methods get the normalized value as argument.
  # The return value of normalize methods replaces the field value.
  # If a validate method returns false then the import fails.
  @normalize = {}
  @validate = {}

  class << self
    attr_reader :columns

    def column_keys
      @column_keys = columns.keys
    end

    def required
      @required ||= columns.keys.select { |key| !columns[key][:optional] }
    end

    def normalize key
      @normalize && @normalize[key]
    end

    def validate key
      @validate && @validate[key]
    end
  end

  attr_reader :errors, :row_index, :import_manager
  attr_accessor :status, :name

  delegate :corrections, :override?, to: :import_manager

  def initialize row, index, import_manager=nil
    @row = row
    @import_manager = import_manager || ImportManager.new(nil)
    # @extra_data = @import_manager.extra_data(index)
    @abort_on_error = true
    @row_index = index # 0-based, not counting the header line
    @errors = []
    @cardid = nil
    merge_corrections
  end

  def import_status
    @import_manager.status
  end

  def log_status
    item = { status: status, id: @cardid }
    item[:errors] = @errors if @errors.present?
    import_status.update_item row_index, item
  end

  def original_row
    @row.merge @before_corrected
  end

  def label
    label = "##{@row_index + 1}"
    label += ": #{@name}" if @name
    label
  end

  def merge_corrections
    corrections.each do |column, hash|
      next unless hash.present? && (old_val = @row[column]) && (new_val = hash[old_val])
      @before_corrected[column] = old_val
      @row[column] = new_val
    end
  end

  def execute_import
    handle_import do
      validate
      ImportLog.debug "start import"
      import
    end
  rescue => e
    ImportLog.debug "import failed: #{e.message}"
    ImportLog.debug e.backtrace
    raise e
  end

  def handle_import
    status = catch(:skip_row) { yield }
    self.status = specify_success_status status
    log_status
      # run_hook status
  end

  # used by csv rows to add additional cards
  def add_card args
    pick_up_card_errors do
      Card.create args
    end
  end

  def validate!
    handle_import do
      validate
      @errors.present? ? :not_ready : :ready
    end
  end

  def validate
    collect_errors { check_required_fields }
    normalize
    collect_errors { validate_fields }
    if (args = try :card_args)
      @cardid = Card.fetch_id args[:name]
    end
  end

  def check_required_fields
    required.each do |key|
      error "value for #{key} missing" unless @row[key].present?
    end
  end

  def collect_errors
    @abort_on_error = false
    yield
    skip :failed if @errors.present?
  ensure
    @abort_on_error = true
  end

  def skip status=:skipped
    throw :skip_row, status
  end

  def error msg
    @errors << msg
    skip :failed if @abort_on_error
  end

  def required
    self.class.required
  end

  def columns
    self.class.columns_keys
  end

  def normalize
    @row.each do |k, v|
      normalize_field k, v
    end
  end

  def validate_fields
    @row.each do |k, v|
      validate_field k, v
    end
  end

  def normalize_field field, value
    return unless (method_name = method_name(field, :normalize))
    @row[field] = send method_name, value
  end

  def validate_field field, value
    return unless (method_name = method_name(field, :validate))
    return if send method_name, value
    error "row #{@row_index + 1}: invalid value for #{field}: #{value}"
  end

  # @param type [:normalize, :validate]
  def method_name field, type
    method_name = "#{type}_#{field}".to_sym
    respond_to?(method_name) ? method_name : self.class.send(type, field)
  end

  def [] key
    @row[key]
  end

  def fields
    @row
  end

  def method_missing method_name, *args
    respond_to_missing?(method_name) ? @row[method_name.to_sym] : super
  end

  def respond_to_missing? method_name, _include_private=false
    @row.keys.include? method_name
  end

  # def report key, msg
  #   msg = "#{msg} duplicate in this file" if key == :duplicate_in_file
  #   import_status[:reports][@current_row.row_index] ||= []
  #   import_status[:reports][@current_row.row_index] << msg
  # end

  # def import_status
  #   @import_status || init_import_status
  # end

  # def report_error msg
  #   import_status.update_item
  #   import_status[:errors][@current_row.row_index] << msg
  # end

  # def errors_by_row_index
  #   @import_status[:errors].each do |index, msgs|
  #     yield index, msgs
  #   end
  # end

  def pick_up_card_errors card=nil
    card = yield if block_given?
    if card
      card.errors.each do |error_key, msg|
        report_error "#{card.name} (#{error_key}): #{msg}"
      end
      card.errors.clear
    end
    card
  end

  def error_list
    @import_status[:errors].each_with_object([]) do |(index, errors), list|
      next if errors.empty?
      list << "##{index + 1}: #{errors.join('; ')}"
    end
  end

  private

  def specify_success_status status
    return status if status.in? %i[failed ready not_ready]
    @status == :overridden ? :overridden : :imported
  end
end
