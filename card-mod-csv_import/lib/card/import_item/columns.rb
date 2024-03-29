class Card
  class ImportItem
    # Use column names as keys and method names as values to define normalization
    # and validation methods.
    # The normalization methods get the original field value as
    # argument. The validation methods get the normalized value as argument.
    # The return value of normalize methods replaces the field value.
    # If a validate method returns false then the import fails.
    @normalize = {}
    @validate = {}

    module Columns
      include ColumnHeaders

      def column_hash
        @column_hash ||= normalize_column_hash
      end

      def column_keys
        @column_keys ||= column_hash.keys
      end

      def required
        @required ||= column_keys.select { |key| !column_hash[key][:optional] }
      end

      def mapped_column_keys
        @mapped_column_keys ||= columns_with_config :map
      end

      def auto_add_types
        @auto_add_types ||= columns_with_config(:auto_add).map do |col|
          map_type col
        end.uniq
      end

      def normalize key
        @normalize && @normalize[key]
      end

      def validate key
        @validate && @validate[key]
      end

      def map key
        @map && @map[key]
      end

      def map_type column
        column_hash[column][:type] || column
      end

      def map_types
        @map_types ||= mapped_column_keys.map { |column| map_type column }.uniq
      end

      def suggest type
        return unless (col_key = columns_for_type(type)&.first)

        column_hash.dig col_key, :suggest
      end

      def suggestion_mark column
        s = suggest column
        s.is_a?(Hash) && s[:mark]
      end

      def separator column
        column_hash.dig column, :separator
      end

      def separate_vals column, val
        return unless (sep = separator column)
        val.split(/\s*#{Regexp.escape sep}\s*/)
      end

      def auto_add type, value
        if respond_to? "auto_add_#{type}"
          send "auto_add_#{type}", value
        else
          auto_add_default type, value
        end
      end

      private

      def auto_add_default type, value
        (Card.create! name: value, type: type)&.id
      end

      def unmapped column
        return unless required.include? column

        raise StandardError, "#{header(column)} column is missing"
      end

      def columns_for_type type
        return [type] if column_hash[type]

        column_keys.select { |col_key| column_hash[col_key][:type] == type }
      end

      def columns_with_config config
        column_keys.select { |col_key| column_hash[col_key][config] }
      end

      def normalize_column_hash
        raise Card::Error, "@columns configuration missing" unless @columns
        case @columns
        when Hash
          @columns
        when Array
          @columns.each_with_object({}) { |col, hash| hash[col] = {} }
        else
          raise Card::Error, "@column configuration must be Hash or Array"
        end
      end
    end

    delegate :required, :column_hash, :mapped_column_keys, :map_type, :column_keys,
             :separator, :separate_vals, to: :class
  end
end
