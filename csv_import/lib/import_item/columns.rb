class ImportItem
  module Columns
    attr_reader :columns

    def column_keys
      @column_keys = columns.keys
    end

    def required
      @required ||= columns.keys.select { |key| !columns[key][:optional] }
    end

    def mapped
      @mapped ||= columns.keys.select { |key| columns[key][:map] }
    end

    def normalize key
      @normalize && @normalize[key]
    end

    def validate key
      @validate && @validate[key]
    end
  end

  delegate :required, :columns, :mapped, to: :class
end