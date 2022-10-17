class Card
  class ImportItem
    module Mapping
      # return id for column value if it exists
      def map_field field, value
        if method_name field, :map
          field_action :map, field, value
        else
          default_mapping field, value
        end
      end

      private

      def default_mapping field, value
        value.card_id unless validate_field field, value
      end

      def merge_mapping
        return unless (m = mapping)

        mapped_column_keys.each do |column|
          error "unmapped #{column}" if unmapped? column, m
        end
      end

      def unmapped? column, mapping
        return false unless (map = mapping[map_type(column)])

        !mapped_value? column, map
      end

      def mapped_value? column, map
        return true unless (old = input[column]) # no val returns true here (see required)
        new = map_value column, map
        case new
        when false, "AutoAdd", "AutoAddFailure" then false # unmapped value
        when old                                then true  # mapped value same as current value
        else
          input[column] = new                              # corrected value from map
        end
      end

      def map_value column, map
        catch :unmapped_value do
          corrected_values = value_array(column).map do |old_value|
            stringify(map[old_value]) || unmapped_value(column)
          end
          corrected_values.compact.join separator(column)
        end
      end

      def stringify value
        value.is_a?(Integer) ? "~#{value}" : value
      end

      def unmapped_value column
        return nil unless column.in? required
        throw :unmapped_value, false
      end
    end
  end
end
