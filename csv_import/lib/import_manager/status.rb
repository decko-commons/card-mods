

# {
#   act_ids: array,
#   items: [[status, cardid, message_hash],[...],...
#   counts: { status: count }
# }


class ImportManager
  class Status < Hash
    STATUS_OPTIONS = %i[failed not_ready ready imported overridden]
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
      self[:items].each do |array|
        array[STATUS_INDEX] = array[STATUS_INDEX].to_sym
      end
    end

    def update_item num, update_hash
      num = num.to_i
      hash = item_hash(num).merge update_hash
      array = [hash.delete(:status), hash.delete(:id)]
      array << hash if hash.present?
      self[:items][num] = array
    end

    def item_hash num
      return {} unless (array = self[:items][num])
      hash = array[2] || {}
      hash.merge status: array[STATUS_INDEX], id: array[ID_INDEX]
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
      counts[:success] = counts[:imported] + counts[:overridden]
      self[:counts] = counts
    end

    def status_indeces status
      items.map.with_index do |item, index|
        index if item.first == status
      end.compact
    end

    def count key
      self[:counts][key]
    end

    def percentage key
      return 0 if count(:total) == 0 || count(key).nil?
      (count(key) / count(:total).to_f * 100).floor(2)
    end
  end
end
