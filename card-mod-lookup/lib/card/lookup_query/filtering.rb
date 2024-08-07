class Card
  class LookupQuery
    # shared filtering methods for query classes built on lookup tables
    module Filtering
      def process_filters
        normalize_filter_args
        return if @empty_result
        @filter_args.each { |k, v| process_filter_option k, v if v.present? }
        @restrict_to_ids.each { |k, v| filter k, v }
      end

      def normalize_filter_args
        # override
      end

      def process_filter_option key, value
        if (method = filter_method key)
          send method, key, value
        else
          try "filter_by_#{key}", value
        end
      end

      def filter_method key
        case key
        when *simple_filters
          :filter_exact_match
        when *card_id_filters
          :filter_card_id
        end
      end

      def filter_exact_match key, value
        filter key, value if value.present?
      end

      def filter_card_id key, value
        return unless (card_id = to_card_id value)

        filter card_id_map[key], card_id
      end

      def filter_by_not_ids value
        add_condition "#{lookup_class.card_column} not in (?)",
                      not_ids_value(value)
      end

      private

      def to_card_id value
        if value.is_a? Array
          value.map(&:card_id)
        else
          value.card_id
        end
      end

      def restrict_to_ids col, ids
        ids = Array(ids)
        @empty_result ||= ids.empty?
        restrict_lookup_ids col, ids
      end

      def restrict_lookup_ids col, ids
        existing = @restrict_to_ids[col]
        @restrict_to_ids[col] = existing ? (existing & ids) : ids
      end

      def restrict_by_cql suffix, col, cql
        q = Card::Query.new cql.merge(table_suffix: suffix)
        @joins << restrict_by_cql_join(q, col, cql)
        @joins << q.sql_statement.joins
        @conditions << q.sql_statement.where(false)

        # cql.reverse_merge! return: :id, limit: 0
        # @conditions << "#{filter_table col}.#{col} IN (#{Card::Query.new(cql).sql})"

        # original strat: list of ids. slightly slower than IN. uglier SQL
        # restrict_to_ids col, Card.search(cql)

        # exists strat: got crazy slow
        # new_cond = "#{filter_table col}.#{col} = c0.#{cql[:return]}"
        # @conditions << "EXISTS (#{Card::Query.new(cql).sql} AND #{new_cond})"
      end

      def filter field, value, operator=nil
        condition = "#{filter_table field}.#{field} #{op_and_val operator, value}"
        add_condition condition, value
      end

      def filter_table _field
        lookup_table
      end

      def op_and_val op, val
        "#{db_operator op, val} #{db_value val}"
      end

      def add_condition condition, value
        @conditions << condition
        @values << value
      end

      def db_operator operator, value
        operator || (value.is_a?(Array) ? "IN" : "=")
      end

      def db_value value
        value.is_a?(Array) ? "(?)" : "?"
      end

      def not_ids_value value
        return value if value.is_a? Array
        value.to_s.split ","
      end

      def restrict_by_cql_join q, col, cql
        on = "ON #{filter_table col}.#{col} = #{q.table_alias}.#{cql[:return] || :id}"
        if cql.key?(:name) && cql.keys.size == 1
          on = "USE INDEX (cards_key_index) #{on} AND #{q.table_alias}.key is not null"
        end
        "JOIN cards #{q.table_alias} #{on}"
      end
    end
  end
end
