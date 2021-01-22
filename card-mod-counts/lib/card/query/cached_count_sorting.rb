class Card
  module Query
    attributes[:item] = :ignore # item is in Card::Query; this shouldn't have to be here.

    module CachedCountSorting
      def sort_by_count_cached_count val
        count_join = CachedCountJoin.new self, val[:right]
        joins << count_join
        @mods[:sort_as] = "integer"
        @mods[:sort] = "#{count_join.to_alias}.value"
      end
    end
  end
end
