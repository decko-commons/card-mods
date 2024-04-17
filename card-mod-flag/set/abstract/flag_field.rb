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
  yield unless left.action.in? %i[create delete]
end
