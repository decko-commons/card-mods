class ImportItem
  # common methods to be used in ImportItem classees
  module HelperMethods
    def comma_list_to_pointer str, comma=","
      str.split(comma).map(&:strip).to_pointer_content
    end

    def to_html value
      value.gsub "\n", "<br>"
    end

    def prep_subfields hash
      hash = select_present hash
      hash.each_key do |field|
        hash[field] = value_array(field) if separator(field)
      end
      hash
    end

    # def prep_value value
    #   value.is_a?(Integer) ? "~#{value}" : value
    # end

    def select_present hash
      hash.select { |_k, v| v.present? }
    end
  end
end
