class ImportManager
  # Methods to collect errors and report the status of the import
  module StatusLog
    def errors? row=nil
      if row
        errors(row).present?
      else
        errors.values.flatten.present?
      end
    end

    def errors
      if row
        import_status.dig(:errors, row.row_index) || []
      else
        import_status[:errors] || {}
      end
    end
  end
end
