class Card
  class ImportItem
    # validation of import fields
    module Validation
      def validate!
        returning_status(:ready) { validate }
      end

      def validate
        @errors = []
        collect_errors { check_required_fields }
        collect_errors(:not_ready) { merge_mapping }
        collect_errors do
          normalize
          validate_fields
        end
        @cardid = detect_existing
      end

      def detect_existing
        if (name = import_hash[:name])
          @cardid = name.card_id
        end
      end

      def each_value
        input.each_key do |field|
          value_array(field).each do |value|
            yield field, value
          end
        end
      end

      def normalize
        each_value do |field, value|
          normalize_field field, value
        end
      end

      private

      def validate_fields
        each_value do |field, value|
          validate_field field, value
        end
      end

      def normalize_field field, value
        field_action :normalize, field, value do |result|
          input[field] = result
        end
      end

      # confusing.  returns nil if valid and @errors (I think) if not
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
          add_error "value for #{key} missing" unless input[key].present?
        end
      end

      def default_validation field, value
        return true if !mapped_column_keys.include?(field)

        Card[value]&.type_code == map_type(field)
      end

      private

      def validation_error field, value
        add_error "invalid #{field}: #{value}"
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
end
