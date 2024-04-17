delegate :lookup_card, :lookup, :lookup_columns, to: :flag_card

def flag_card
  left
end

event :update_flaggable_lookup_field, :finalize, changed: :content, when: :lookup? do
  lookup_field_update do
    lookup.refresh(*Array.wrap(lookup_columns))
  end
end

private

def lookup?
  lookup_card.respond_to? :lookup
end

def lookup_field_update
  yield # unless left.action.in? %i[create delete]
  # FIXME: the code commented above should work.
  # it used to say "lookup_card" rather than "left", which is too literal a translation
  # from LookupField - the lookup card is not involved in the action at all.
  # Instead the problem is that the flag card itself is not trigerring any actions.
  # Until we fix that, this should work, but it probably will involve multiple refreshes
  # when multiple fields are edited at once. (eg on create and delete)
end
