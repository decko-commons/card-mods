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
      corrections.each do |column, hash|
        next unless hash.present?
        if (old = @row[column]) && (new = hash[old])
          record_correction column, old, new unless old == new
        else
          error "unmapped #{column.cardname}"
        end
      end
    end

    def record_correction column, old, new
      @before_corrected[column] = old
      @row[column] = new
    end
  end
end
