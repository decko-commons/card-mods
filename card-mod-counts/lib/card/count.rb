class Card
  # store counts of cards in the db
  class Count < ActiveRecord::Base
    extend ClassMethods

    def step
      update! value: value + 1
      value
    end

    def recount card
      Error.rescue_card card do
        update! value: card.recount, flag: false
        card.hard_cached_count value
      end
    end

    def refresh
      if (c = card)
        recount(c).tap { c.expire }
      else
        delete
      end
    rescue StandardError
    end

    def flag
      update! flag: true
    end

    def card
      if right_id == -1
        left_id&.card
      else
        Card.fetch [left_id, right_id]
      end
    end
  end
end
