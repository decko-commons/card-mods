class Card
  # Inherit from Card::ImportItem to describe and process a import item.
  # Card::ImportCsv creates an instance of ImportItem for every row and calls #import on it
  class ImportItem
    include ::Card::Model::SaveHelper

    extend Columns
    include HelperMethods
    include Validation
    include Mapping

    attr_reader :errors, :cardid, :import_manager, :input, :status
    attr_accessor :name

    delegate :conflict_strategy, :abort_on_error, :mapping, to: :import_manager

    def initialize input_hash, import_manager: nil
      @input = input_hash
      @import_manager = import_manager || ImportManager.new(nil)
      @errors = []
      @conflict = nil
      @cardid = nil
    end

    def import_hash
      # FIXME: make reasonable default!
      {}
    end

    def import
      returning_status :success do
        validate
        ImportLog.debug "start import"
        handling_conflicts do
          import_card import_hash
        end
      end
    end

    def skip status=:skipped
      throw :skip_row, status
    end

    def error msg
      @errors << msg
    end

    def [] key
      input[key]
    end

    def value_array key
      val = self[key]
      if val.blank?
        []
      else
        separate_vals(key, val) || [val]
      end
    end

    def export_csv_line _status
      CSV.generate_line column_keys.map { |ck| input[ck] }
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

    def returning_status default_status
      status_value = catch :skip_row do
        rescuing_errors { yield }
        default_status
      end
      @status = status_hash status_value
    end

    def rescuing_errors
      yield
    rescue StandardError => e
      major_error e
      raise e if abort_on_error
    end

    def status_hash status_value
      { status: status_value, id: @cardid }.tap do |hash|
        hash[:errors] = @errors if @errors.present?
        hash[:conflict] = @conflict if @conflict.present?
      end
    end

    # add the final import card
    def import_card card_args
      pick_up_card_errors do
        self.name = card_args[:name]
        card = Card.fetch self.name, new: card_args
        if card.real?
          card.update card_args
        else
          card.save
        end
        @cardid = card.id if card.id
        card
      end
    end

    def method_missing method_name, *args
      respond_to_missing?(method_name) ? input[method_name.to_sym] : super
    end

    def respond_to_missing? method_name, _include_private=false
      input.keys.include? method_name
    end

    def pick_up_card_errors
      card = yield
      return card unless card.errors.any?

      card.errors.each do |error|
        error "#{card.name} (#{error.attribute}): #{error.message}"
      end
      card.errors.clear
      skip :failed
    end

    def major_error error
      error error.message
      ImportLog.debug "import failed: #{error.message}"
      ImportLog.debug error.backtrace.join "\n"
      skip :failed
    end
  end
end
