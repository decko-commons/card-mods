include_set Abstract::Pointer

event :validate_mirrorable, :validate, on: :save, changed: :name do
  return if right&.type_code == :cardtype

  errors.add :name, t(:mirror_cardtype_right)
end

event :validate_mirror_items, :validate, on: :save do
  item_cards.each do |item_card|
    next if item_card.type_id == item_type_id

    errors.add :content, t(:mirror_only_type_allowed,
                           cardname: item_card.name,
                           cardtype: item_type_name)
  end
end

event :update_mirroring_card, :prepare_to_validate,
      changed: :content, skip: :allowed do
  remove_mirrored_items dropped_item_names
  add_mirrored_items added_item_names
end

def remove_mirrored_items items
  each_mirrored_subcard(items) { |sc| sc.drop_item name.left }
end

def add_mirrored_items items
  each_mirrored_subcard(items) { |sc| sc.add_item name.left }
end

def each_mirrored_subcard items
  items.each do |item|
    sc = subcard mirrored_card(item)
    sc.skip_event! :update_mirroring_card
    yield sc
  end
end

def mirrored_card item
  Card.fetch [item, left.type_name], new: { type: mirroring_type }
end

def generate_content
  listed_by.map { |item| item.to_name.left }.join "\n"
end

def listed_by
  Card.search({ type: :mirrored_list,
                right: trunk.type_name,
                left: { type_id: item_type_id },
                refer_to: name.trunk,
                return: :name }, "all cards listed by #{name}")
end

def item_type_id
  right_id
end

