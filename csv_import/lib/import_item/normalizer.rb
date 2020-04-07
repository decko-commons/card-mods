class ImportItem
  # common methods to be used to normalize values
  module Normalizer
    def comma_list_to_pointer str, comma=","
      str.split(comma).map(&:strip).to_pointer_content
    end

    def to_html value
      value.gsub "\n", "<br>"
    end
  end
end
