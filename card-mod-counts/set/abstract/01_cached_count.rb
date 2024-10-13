# -*- encoding : utf-8 -*-

# Cards in this set cache a count in the counts table

def self.included host_class
  host_class.extend ClassMethods
end

def cached_count
  @cached_count || hard_cached_count(Count.value(self))
end

def hard_cached_count value
  Card.cache.shared&.write_attribute key, :cached_count, value
  @cached_count = value
end

# called to refresh the cached count
# the default way is that the card is a search card and we just
# count the search result
# for special calculations override this method in your set
def recount
  count
end

def update_cached_count
  if Cardio.config.card_count == :flag
    Count.flag self
  else
    Count.refresh self
  end
end

def refresh_cached_count
  Count.refresh self
end

module ClassMethods
  # trigger a recount
  # The set in which the #recount_trigger method is called is usually the set counted.
  # This makes it easy to see all the events that update that card.
  # The block should use the changed card to find the relevant cards in the current
  # set that should be recounted.
  # @param parts [Array] set parts of card that, when changed, should trigger a recount
  def recount_trigger *set_parts, &block
    event_args = set_parts.last.is_a?(Hash) ? set_parts.pop : {}
    set = ensure_set { set_parts }
    event_name = recount_event_name set, event_args[:on]
    define_recount_event set, event_name, event_args, &block
  end

  # use in cases where both the base card and the field card can trigger counting
  # (prevents double work)
  def field_recount_trigger *set_parts
    recount_trigger(*set_parts) do |field_card|
      yield field_card unless field_card.left&.action&.in? %i[create delete]
    end
  end

  private

  def define_recount_event set, event_name, event_args
    set.class_eval do
      event event_name, :after_integrate, event_args do
        Array.wrap(yield(self)).compact.each(&:update_cached_count)
      end
    end
  end

  def recount_event_name set, on
    changed_set = set.to_s.tr(":", "_").underscore
    count_set = to_s.tr(":", "_").underscore
    on_actions = on.present? ? "_on_#{Array.wrap(on).join '_'}" : nil
    :"recount_#{count_set}_triggered_by_#{changed_set}#{on_actions}"
  end
end

format do
  def count
    card.cached_count
  end
end
