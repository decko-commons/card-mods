class Card
  # store counts of cards in the db
  class Count
    # Card::Count class methods
    module ClassMethods
      include BulkMethods

      def value card
        find_value_by_card(card) || create(card).value
      end

      def step card
        count = find_by_card card
        count ? count.step : create(card).value
      end

      def refresh card
        count = find_by_card card
        count ? count.recount(card) : create(card).value
      end

      def flag card
        count = find_by_card card
        count ? count.flag : create(card, flag: true)
      end

      private

      def fetch card
        find_by_card(card) || create(card)
      end

      def create card, flag: false
        validate_count_card card
        args = { left_id: left_id(card),
                 right_id: right_id(card),
                 flag: flag,
                 value: (flag ? 1 : card.recount) }
        count = new args
        count.save!
        count
      end

      def find_by_card card
        where_card(card).take
      end

      def find_value_by_card card
        where_card(card).pluck(:value).first
      end

      def where_card card
        where left_id: left_id(card), right_id: right_id(card)
      end

      def left_id card
        if card.compound?
          card.left_id || ((l = card.left) && l.id)
        else
          card.id
        end
      end

      def right_id card
        if card.compound?
          card.right_id || ((r = card.right) && r.id)
        else
          -1
        end
      end

      def validate_count_card card
        invalidity = reason_invalid card
        return unless invalidity

        raise Error, card.name, "count not cacheable: card #{card.name} #{invalidity}"
      end

      def reason_invalid card
        if !card.respond_to? :recount
          "has no 'recount' method"
        elsif card.compound?
          reason_compound_card_invalid card
        elsif !card.id
          "needs id"
        end
      end

      def reason_compound_card_invalid card
        if !left_id(card)
          "needs left_id"
        elsif !right_id(card)
          "needs right_id"
        end
      end
    end
  end
end
