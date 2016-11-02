def add_id new_id
  add_item vote_key(new_id)
end

def drop_id id
  drop_item vote_key(id)
end

def insert_id_before new_id, successor_id
  drop_id new_id
  if (index = item_names.index vote_key(successor_id))
    insert_item index, vote_key(new_id)
  else
    add_item vote_key(new_id)
  end
end

def followable?
  # we may want these to be followable at some point,
  # but for now we are skipping that to optimize
  false
end
