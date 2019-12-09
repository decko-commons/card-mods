class Card
  module Bookmark
    class << self
      def ok?
        Auth.signed_in? && Auth.current.respond_to?(:bookmarks_card)
      end

      # @return Hash key is type_id, value is list of ids
      def current_bookmarks
        bookmark_list do
          current_list_card.item_cards.each_with_object({}) do |item, hash|
            hash[item.type_id] ||= []
            hash[item.type_id] << item.id
          end
        end
      end

      def current_list_card
        Auth.current.bookmarks_card if ok?
      end

      def current_ids
        cache.fetch "BM-current_ids" do # MOVE to session?
          ok? ? current_list_card.item_ids : []
        end
      end

      def bookmark_list
        ok? ? yield : []
      end

      def id_restriction bookmarked=true
        if current_ids.empty?
          bookmarked ? [] : nil
        else
          [(bookmarked ? "in" : "not in")] + current_ids
        end
      end

      def cache
        Card.cache.soft
      end
    end
  end
end