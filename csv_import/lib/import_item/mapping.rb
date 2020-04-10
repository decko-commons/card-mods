class ImportItem
  module Mapping
    def map_field field
      value = self[field]
      if method_name field, :validate
        field_action :map, field, value
      else
        default_mapping field, value
      end
    end

    def default_mapping field, value
      card = Card[value]
      return unless card&.type_code&.in? Array.wrap(map_type(field))

      card.id
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
