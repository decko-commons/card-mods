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
    def column_hash
      @column_hash ||= normalize_column_hash
    end

    def column_keys
      @column_keys = column_hash.keys
    end

    def required
      @required ||= column_keys.select { |key| !column_hash[key][:optional] }
    end

    def mapped
      @mapped ||= column_keys.select { |key| column_hash[key][:map] }
    end

    def normalize key
      @normalize && @normalize[key]
    end

    def validate key
      @validate && @validate[key]
    end

    def normalize_column_hash
      raise Card::UserError, "@columns configuration missing" unless @columns
      case @columns
      when Hash
        @columns
      when Array
        @columns.each_with_object({}) do |col, hash|
          hash[col] = nil
        end
      end
    end
  end

  delegate :required, :column_hash, :mapped, to: :class
end