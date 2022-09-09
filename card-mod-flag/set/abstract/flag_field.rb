delegate :lookup_card, :lookup, :lookup_columns, to: :flag_card

def flag_card
  left
end

event :update_flaggable_lookup_field, :finalize, changed: :content do
  lookup_field_update do
    lookup.refresh(*Array.wrap(lookup_columns))
  end
end

private

def lookup_field_update
  yield unless lookup_card.action.in? %i[create delete]
end
