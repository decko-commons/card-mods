class Card
  # store counts of cards in the db
  class Count < ActiveRecord::Base
    def step
      update value + 1
    end

    def update new_value
      update! value: new_value
      new_value
    end

    def card
      Card.fetch([left_id, right_id])
    end

    class << self
      def create card
        validate_count_card card
        count = new left_id: left_id(card),
                    right_id: right_id(card),
                    value: card.recount
        count.save!
        count
      end

      def fetch_value card
        find_value_by_card(card) || create(card).value
      end

      def fetch card
        find_by_card(card) || create(card)
      end

      def step card
        count = find_by_card(card)
        return create(card).value unless count
        count.step
      end

      def refresh card
        count = find_by_card(card)
        return create(card).value unless count
        count.update card.recount
      end

      def find_value_by_card card
        where_card(card).pluck(:value).first
      end

      def find_by_card card
        where_card(card).take
      end

      private

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
