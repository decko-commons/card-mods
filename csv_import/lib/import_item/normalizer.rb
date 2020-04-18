class ImportItem
  # common methods to be used to normalize values#
  # TODO: rename this to HelperMethods
  module Normalizer
    def comma_list_to_pointer str, comma=","
      str.split(comma).map(&:strip).to_pointer_content
    end

    def to_html value
      value.gsub "\n", "<br>"
    end

    def select_present hash
      hash.select { |_k, v| v.present? }
    end
  end
end
