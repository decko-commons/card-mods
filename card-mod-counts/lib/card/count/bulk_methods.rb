class Card
  # store counts of cards in the db
  class Count
    module BulkMethods
      def refresh_flagged
        each_flagged &:refresh
      end

      def each_flagged
        where(flagged: true).find_in_batches do |group|
          group.each do |count|
            yield count
          end
        end
      end
    end
  end
end
