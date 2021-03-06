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

      def default_mapping field, value
        Card.fetch_id value unless validate_field field, value
      end

      def merge_mapping
        return unless mapping
        mapped_column_keys.each do |column|
          next unless (map = mapping[map_type(column)])
          error "unmapped #{column}" unless mapped_value? column, map
        end
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

      def unmapped_value column
        return nil unless column.in? required
        throw :unmapped_value, false
      end

      def stringify value
        value.is_a?(Integer) ? "~#{value}" : value
      end
    end
  end
end
