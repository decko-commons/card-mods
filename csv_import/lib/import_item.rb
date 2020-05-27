# Inherit from ImportItem to describe and process a import item.
# CsvFile creates an instance of ImportItem for every row and calls #execute_import on it
class ImportItem
  include ::Card::Model::SaveHelper

  extend Columns
  include HelperMethods
  include Validation
  include Mapping

  attr_reader :errors, :index, :cardid, :import_manager
  attr_accessor :status, :name
  attr_writer :corrections

  delegate :status, :conflict_strategy, to: :import_manager

  def initialize row, index=0, import_manager=nil, abort_on_error: false
    @row = row
    @import_manager = import_manager || ImportManager.new(nil)
    @abort_on_error = abort_on_error
    @index = index # 0-based, not counting the header line
    @errors = []
    @conflict = nil
    @auto_add = {}
    @cardid = nil
    @before_corrected = {}
  end

  def import_hash
    # FIXME: make reasonable default!
    {}
  end

  def status_hash
    status.item_hash index
  end

  def original_row
    @row.merge @before_corrected
  end

  def corrections
    @corrections ||= import_manager.corrections
  end

  def import
    logging_status :success do
      validate
      ImportLog.debug "start import"
      handling_conflicts do
        import_card import_hash
      end
    end
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

  def value_array key
    val = self[key]&.strip
    if val.blank?
      []
    elsif (sep = separator key)
      val.split(/\s*#{Regexp.escape sep}\s*/)
    else
      [val]
    end
  end

  def fields
    @row
  end

  private

  def handling_conflicts
    return yield unless @cardid
    if conflict_strategy == :skip
      @conflict = :skipped
    else
      yield
      @conflict = :overridden
    end
  end

  def logging_status default_status
    status_value = catch :skip_row do
      rescuing_errors { yield }
      default_status
    end
    log_status status_value
  end

  def rescuing_errors
    yield
  rescue StandardError => e
    major_error e
    raise e if @abort_on_error
  end

  def log_status status_value
    return unless status

    item = { status: status_value, id: @cardid }
    item[:errors] = @errors if @errors.present?
    item[:conflict] = @conflict if @conflict.present?
    status.update_item index, item
  end

  # add the final import card
  def import_card card_args
    pick_up_card_errors do
      self.name = card_args[:name]
      card = Card.fetch self.name, new: card_args
      card.save
      @cardid = card.id if card.id
      card
    end
  end

  def method_missing method_name, *args
    respond_to_missing?(method_name) ? @row[method_name.to_sym] : super
  end

  def respond_to_missing? method_name, _include_private=false
    @row.keys.include? method_name
  end

  def pick_up_card_errors
    card = yield
    return card unless card.errors.any?

    card.errors.each do |error_key, msg|
      error "#{card.name} (#{error_key}): #{msg}"
    end
    card.errors.clear
    skip :failed
  end

  def major_error error
    error error.message
    ImportLog.debug "import failed: #{error.message}"
    ImportLog.debug error.backtrace
    skip :failed
  end
end
