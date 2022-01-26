# -*- encoding : utf-8 -*-

# Cards in this set cache a count in the counts table

def self.included host_class
  host_class.extend ClassMethods
end

def cached_count
  @cached_count || hard_cached_count(::Count.fetch_value(self))
end

def hard_cached_count value
  Card.cache.hard&.write_attribute key, :cached_count, value
  @cached_count = value
end

# called to refresh the cached count
# the default way is that the card is a search card and we just
# count the search result
# for special calculations override this method in your set
def recount
  count
end

event :update_cached_count, :integrate_with_delay, trigger: :required, priority: 15 do
  hard_cached_count ::Count.refresh(self)
end

# cannot delay event without id
# TODO: fix or explain better
def update_cached_count_when_ready
  send "update_cached_count#{'_without_callbacks' if new?}"
end

module ClassMethods
  # @param parts [Array] set parts of changed card
  def recount_trigger *set_parts, &block
    event_args = set_parts.last.is_a?(Hash) ? set_parts.pop : {}
    set = ensure_set { set_parts }
    event_name = recount_event_name set, event_args[:on]
    define_recount_event set, event_name, event_args, &block
  end

  # use in cases where both the base card and the field card can trigger counting
  # (prevents double work)
  def field_recount field_card
    yield unless field_card.left&.action&.in? %i[create delete]
  end

  private

  def define_recount_event set, event_name, event_args
    set.class_eval do
      event event_name, :after_integrate, event_args do
        Array.wrap(yield(self)).compact.each(&:update_cached_count_when_ready)
      end
    end
  end

  def recount_event_name set, on
    changed_set = set.to_s.tr(":", "_").underscore
    count_set = to_s.tr(":", "_").underscore
    on_actions = on.present? ? "_on_#{Array.wrap(on).join '_'}" : nil
    :"update_cached_count_for_#{count_set}_triggered_by_#{changed_set}#{on_actions}"
  end
end

format do
  def count
    card.cached_count
  end
end
