class Card
  # base class for query classes built on lookup tables
  class LookupQuery
    include Filtering
    include Sorting

    attr_accessor :filter_args, :sort_args, :paging_args
    class_attribute :card_id_map, :card_id_filters, :simple_filters

    def initialize filter, sorting={}, paging={}
      @filter_args = filter
      @sort_args = sorting
      @paging_args = paging

      @conditions = []
      @joins = []
      @values = []
      @restrict_to_ids = {}

      process_sort
      process_filters
    end

    def lookup_query
      q = lookup_class.where lookup_conditions
      q = q.joins(@joins.uniq) if @joins.present?
      q
    end

    def lookup_table
      @lookup_table ||= lookup_class.arel_table.name
    end

    def condition_sql conditions
      lookup_class.sanitize_sql_for_conditions conditions
    end

    def lookup_relation
      sort_and_page { lookup_query }
    end

    # @return args for AR's where method
    def lookup_conditions
      return "true = false" if @empty_result

      condition_sql [@conditions.join(" AND ")] + @values
    end

    # @return [Array]
    def run
      @empty_result ? [] : main_results
    end

    # @return [Integer]
    def count
      # we need the id because some joins distort the count
      @empty_result ? 0 : main_query.select("#{lookup_table}.id").distinct.count
    end

    def limit
      @paging_args[:limit]
    end

    def main_query
      @main_query ||= lookup_query
    end

    def main_results
      relation_to_ids(lookup_relation).map(&:card)
    end

    private

    def relation_to_ids relation
      relation.map(&:card_id).tap do |ids|
        Cache.populate_ids ids
      end
    end
  end
end
