class Card
  # store counts of cards in the db
  class Count
    # Card::Count bulk methods
    module BulkMethods
      def refresh_flagged
        each_flagged(&:refresh)
      end

      def each_flagged
        where(flag: true).find_in_batches do |group|
          group.each do |count|
            yield count
          end
          Card::Cache.reset_soft
        end
      end
    end
  end
end
