class ImportItem
  # validation of import fields
  module Validation
    def validate!
      logging_status(:ready) { validate }
    end

    def validate
     collect_errors { check_required_fields }
     collect_errors(:not_ready) { merge_corrections }
     collect_errors do
       normalize
       validate_fields
     end
     detect_existing
    end

    def detect_existing
      if (name = import_hash[:name])
        @cardid = Card.fetch_id name
      end
    end

    def normalize
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

    def collect_errors status=:failed
      yield
      skip status if @errors.present?
    end
  end
end