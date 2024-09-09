class Card
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
        reason = "has to respond to 'recount'" unless card.respond_to? :recount
        reason ||=
          if card.compound?
            "needs left_id" unless left_id(card)
            "needs right_id" unless right_id(card)
          elsif !card.id
            "needs id"
          end
        return unless reason
        raise Error, card.name, "count not cacheable: card #{card.name} #{reason}"
      end
    end
  end
end
