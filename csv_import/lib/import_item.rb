# Inherit from ImportItem to describe and process a import item.
# CsvFile creates an instance of ImportItem for every row and calls #execute_import on it
class ImportItem
  include ::Card::Model::SaveHelper

  extend Columns
  include Normalizer
  include Validation
  include Mapping

  attr_reader :errors, :row_index, :import_manager
  attr_accessor :status, :name

  delegate :override?, to: :import_manager

  def initialize row, index=0, import_manager=nil, abort_on_error: false
    @row = row
    @import_manager = import_manager
    @abort_on_error = abort_on_error
    @row_index = index # 0-based, not counting the header line
    @errors = []
    @cardid = nil
    @before_corrected = {}
  end

  def import_hash
    # FIXME: make reasonable default!
    {}
  end

  def original_row
    @row.merge @before_corrected
  end

  def import
    handle_import do
      validate
      ImportLog.debug "start import"
      import_card import_hash
    end
  rescue => e
    log_error e
    raise e if @abort_on_error
  ensure
    yield self if block_given?
  end

  def skip status=:skipped
    throw :skip_row, status
  end

  def error msg
    @errors << msg
  end

  def [] key
    @row[key]
  end

  def fields
    @row
  end

  private

  def import_status
    import_manager&.status
  end

  def log_status
    return unless import_status

    item = { status: status, id: @cardid }
    item[:errors] = @errors if @errors.present?
    import_status.update_item row_index, item
  end

  def corrections
    import_manager&.corrections || []
  end

  def log_error error
    ImportLog.debug "import failed: #{error.message}"
    ImportLog.debug error.backtrace
  end

  def handle_import
    status = catch(:skip_row) { yield }
    self.status = specify_success_status status
    log_status
    # run_hook status
  end

  # add the final import card
  def import_card card_args
    pick_up_card_errors do
      self.name = card_args[:name]
      card = Card.fetch self.name, new: card_args
      card.save
      card
    end
  end

  def method_missing method_name, *args
    respond_to_missing?(method_name) ? @row[method_name.to_sym] : super
  end

  def respond_to_missing? method_name, _include_private=false
    @row.keys.include? method_name
  end

  def pick_up_card_errors card=nil
    card = yield if block_given?
    if card
      card.errors.each do |error_key, msg|
        error "#{card.name} (#{error_key}): #{msg}"
      end
      card.errors.clear
    end
    card
  end

  def specify_success_status status
    return status if status.in? %i[failed ready not_ready]
    @status == :overridden ? :overridden : :imported
  end
end
