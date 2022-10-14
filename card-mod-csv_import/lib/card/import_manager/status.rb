# TODO: optimize
# We should keep the (less repetitive) json format as it is,
# but only convert to that format when we're ready to store.

# {
#   act_ids: array,
#   items: [[status, cardid, message_hash],[...],...
#   counts: { status: count }
# }
class Card
  class ImportManager
    class Status < Hash
      STATUS_OPTIONS = %i[not_ready ready importing failed success]
      STATUS_INDEX = 0
      ID_INDEX = 1
      EXTRAS_INDEX = 2

      def initialize hash={}
        replace hash.reverse_merge(act_ids: [], items: [], counts: {})
        normalize
      end

      def normalize
        symbolize_keys!
        self[:counts].symbolize_keys!
        items.each do |array|
          array[STATUS_INDEX] = array[STATUS_INDEX].to_sym
          array[EXTRAS_INDEX]&.symbolize_keys!
        end
      end

      def update_item num, update_hash
        num = num.to_i
        hash = simple_item_hash(num).merge update_hash # drops conflict/error info
        array = [hash.delete(:status), hash.delete(:id)]
        array << hash if hash.present?
        self[:items][num] = array
        recount
      end

      def item_hash num
        with_item_array num do |array|
          (array[EXTRAS_INDEX] || {}).merge simple_item_hash(num)
        end
      end

      def items
        self[:items]
      end

      def item_errors num
        item_hash(num)&.dig :errors
      end

      def errors
        (0..items.length).map do |num|
          item_errors num
        end.flatten.compact
      end

      def recount
        counts = { total: items.size }
        STATUS_OPTIONS.each do |option|
          counts[option] = items.select { |i| i.first == option }.size
        end
        self[:counts] = counts
      end

      def status_indices status
        items.map.with_index do |item, index|
          index if item.first == status
        end.compact
      end

      def count key
        self[:counts][key].to_i
      end

      def percentage key
        return 0 if count(:total) == 0 || count(key).nil?
        (count(key) / count(:total).to_f * 100).floor(2)
      end

      private

      def with_item_array num
        return {} unless (array = items[num])

        yield array
      end

      def simple_item_hash num
        with_item_array num do |array|
          { status: array[STATUS_INDEX], id: array[ID_INDEX] }
        end
      end
    end
  end
end
