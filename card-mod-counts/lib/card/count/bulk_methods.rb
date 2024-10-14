class Card
  # store counts of cards in the db
  class Count
    # Card::Count bulk methods
    module BulkMethods
      # flag counts for all combinations of left_ids and right_ids
      def flag_all left_ids, right_ids, increment: 0
        flag_all_existing left_ids, right_ids, increment
        flag_all_missing left_ids, right_ids, (increment.positive? ? increment : 0)
      end

      # refresh counts for each flagged answer
      def refresh_flagged
        each_flagged(&:refresh)
      end

      private

      def flag_all_existing left_ids, right_ids, increment
        left_ids.each_slice(5000) do |slice|
          where(left_id: slice, right_id: right_ids)
            .update_all "value = value + #{increment}, flag = true"
        end
      end

      def flag_all_missing left_ids, right_ids, increment
        right_ids.each do |right_id|
          left_ids.each_slice(1000) do |slice|
            exist = where(left_id: slice, right_id: right_id).pluck :left_id
            missing = slice - exist
            insert_missing missing, right_id, increment
          end
        end
      end

      def insert_missing left_ids, right_id, value
        return unless left_ids.present?

        new_counts = left_ids.map do |left_id|
          { left_id: left_id, right_id: right_id, value: value, flag: true }
        end
        insert_all new_counts
      end

      def each_flagged &block
        where(flag: true).find_in_batches do |group|
          group.each(&block)
          Card::Cache.reset_temp
        end
      end
    end
  end
end
