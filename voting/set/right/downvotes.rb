def add_id new_id
  add_item "~#{new_id}"
end

def drop_id id
  drop_item "~#{id}"
end

def insert_id_before new_id, successor_id
  drop_id new_id
  if (index = item_names.index "~#{successor_id}")
    insert_item index, "~#{new_id}"
  else
    add_item "~#{new_id}"
  end
end
