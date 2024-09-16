class Card
  # store counts of cards in the db
  class Count < ActiveRecord::Base
    extend ClassMethods

    def step
      update value + 1
    end

    def update card
      new_value = card.recount
      return if new_value == value
      update! value: new_value
      card.hard_cached_count value
      new_value
    end

    def refresh
      if (c = card)
        update c
      else
        delete
      end
    end

    def card
      if right_id == -1
        left_id.card
      else
        Card.fetch([left_id, right_id])
      end
    end
  end
end
