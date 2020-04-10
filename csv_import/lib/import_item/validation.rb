class ImportItem
  # validation of import fields
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
      if (name = import_hash[:name])
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
      field_action :normalize, field, value do |result|
        @row_field = result
      end
    end

    def validate_field field, value
      valid =
        if method_name field, :validate
          field_action :validate, field, value
        else
          default_validation field, value
        end
      validation_error field, value unless valid
    end

    def check_required_fields
      required.each do |key|
        error "value for #{key} missing" unless @row[key].present?
      end
    end

    def default_validation field, value
      return true unless mapped_column_keys.include? field

      Card[value]&.type_code == field
    end

    private

    def validation_error field, value
      error "invalid #{field}: #{value}"
    end

    def field_action action, field, value
      return unless (method_name = method_name(field, action))
      result = send method_name, value
      block_given? ? yield(result) : result
    end

    # @param type [:normalize, :validate]
    def method_name field, type
      method_name = "#{type}_#{field}".to_sym
      respond_to?(method_name) ? method_name : self.class.send(type, field)
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