class Card
  class ImportItem
    # labels for import item columns
    module ColumnHeaders
      def headers
        @headers ||= column_keys.map { |column| header column }
      end

      def header column
        column_hash[column][:header]&.to_name || autoheader(column)
      end

      def header_alias column
        column_hash[column][:alias]&.to_name
      end

      def export_csv_header
        CSV.generate_line headers
      end

      # FOR TESTING :

      # @return [Hash] { column_key_0 => 0, column_key_1 => 1 }
      def map_headers names
        names = names.map(&:to_name)
        column_keys.each_with_object({}) do |column, hash|
          num = names.index header(column)
          num ||= (ha = header_alias column) && names.index(ha)
          unmapped column unless (hash[column] = num)
        end
      end

      # @return [Hash] { column_key_0 => 0, column_key_1 => 1 }
      def default_header_map
        column_keys.zip((0..column_keys.size)).to_h
      end
    end
  end
end
