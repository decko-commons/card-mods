class Card
  # base class for query classes built on lookup tables
  class LookupQuery
    include Filtering

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
      # puts "SQL: #{lookup_relation.to_sql}"
      ids = lookup_relation.map(&:card_id)
      Cache.populate_ids ids
      ids.map(&:card)
    end

    private

    def sort_and_page
      relation = yield
      @sort_joins.uniq.each { |j| relation = relation.joins(j) }
      if @sort_hash.present?
        select = ["#{lookup_table}.*", sort_fields].flatten.compact
        relation = relation.select(select).distinct
      end
      relation.sort(@sort_hash).paging(@paging_args)
    end

    def process_sort
      @sort_joins = []
      @sort_hash = @sort_args.each_with_object({}) do |(by, dir), h|
        h[sort_by(by)] = sort_dir(dir)
      end
    end

    def sort_fields
      @sort_hash.keys.map do |key|
        return nil if key == :random

        if key.match?(/_bookmarkers$/)
          "cts.value as bookmarkers"
        else
          Card::Query.safe_sql key
        end
      end
    end

    def sort_by sort_by
      if (id_field = sort_by_cardname[sort_by])
        sort_by_cardname_join sort_by, lookup_table, id_field
      elsif sort_by == :random
        "rand()"
      else
        simple_sort_by sort_by
      end
    end

    def sort_by_cardname
      {}
    end

    def sort_dir dir
      dir
    end

    def simple_sort_by sort_by
      sort_by
    end

    def sort_by_cardname_join sort_by, from_table, from_id_field
      @sort_joins <<
        "JOIN cards AS #{sort_by} USE INDEX (cards_key_index) " \
          "ON #{sort_by}.id = #{from_table}.#{from_id_field} " \
          "AND #{sort_by}.key IS NOT NULL"
      "#{sort_by}.key"
    end
  end
end
