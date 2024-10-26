class Card
  class LookupQuery
    # shared sorting methods for query classes built on lookup tables
    module Sorting
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
            Query.safe_sql key
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
end
