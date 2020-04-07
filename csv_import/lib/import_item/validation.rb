class ImportItem
  # common methods to be used to normalize values
  module Validation

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
      if (name = card_args[:name])
        @cardid = Card.fetch_id name
      end
    end


    def normalize
      merge_corrections
      @row.each do |k, v|
        normalize_field k, v
      end
    end


    private

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

    def merge_corrections
      corrections.each do |column, hash|
        next unless hash.present?
        skip :not_ready unless (old = @row[column]) && (new = hash[old])
        next if old == new
        @before_corrected[column] = old
        @row[column] = new
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
  end
end