class Card
  class ImportItem
    # common methods to be used in ImportItem classees
    module HelperMethods
      def prep_fields hash
        hash = select_present hash
        hash.each_key do |field|
          hash[field] = { content: value_array(field) } if separator(field)
        end
        hash
      end

      private

      def select_present hash
        hash.select { |_k, v| v.present? }
      end
    end
  end
end
