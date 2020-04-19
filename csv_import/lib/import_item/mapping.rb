class ImportItem
  module Mapping
    # return id for column value if it exists
    def map_field field
      value = self[field]
      if method_name field, :map
        field_action :map, field, value
      else
        default_mapping field, value
      end
    end

    def default_mapping field, value
      Card.fetch_id value unless validate_field field, value
    end

    def merge_corrections
      corrections.each do |column, map|
        next unless map.present?

        correct_value(column, map) || error("unmapped #{column}")
      end
    end

    def correct_value column, map
      return true unless (old = @row[column]) # no val returns true here (see required)

      new = catch(:unmapped_value) { correct_from_map column, map }
      case new
      when false
        false
      when old
        true
      else
        record_correction column, old, new
      end
    end

    def correct_value_from_map column, map
      corrected_values = value_array(column).map do |old_value|
        map[old_value] || throw(:unmapped_value, false)
      end
      corrected_values.join separator
    end

    def record_correction column, old, new
      @before_corrected[column] = @row_column
      @row[column] = new
    end
  end
end
