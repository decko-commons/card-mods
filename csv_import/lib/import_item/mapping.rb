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
      status = catch(:skip_row) { validate_field field, value }
      status == :failed ? nil : Card.fetch_id(value)
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
  end
end
