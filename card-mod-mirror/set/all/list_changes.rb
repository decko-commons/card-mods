# -*- encoding : utf-8 -*-

def list_fields
  Card.search({ left: name, type_id: Card::MirroredListID }, "list fields")
end

def listed_by_fields
  Card.search({ left: name, type_id: Card::MirrorListID }, "listed by fields")
end

def linker_lists
  Card.search({ type_id: Card::MirroredListID, link_to: name },
              "lists that link to #{name}")
end

def codename_list_exist?
  Codename.exists?(:mirrored_list) && Codename.exists?(:mirror_list)
end

event :trunk_cardtype_of_a_list_relation_changed, :finalize,
      changed: :type, on: :update, when: :codename_list_exist? do
  type_key_was = Card.quick_fetch(type_id_before_act)&.key

  list_fields.each do |card|
    card.update_listed_by_cache_for card.item_keys, type_key: type_key_was
    card.update_listed_by_cache_for card.item_keys
  end
  listed_by_fields.each &:update_cached_list
end

event :trunk_name_of_a_list_relation_changed, :finalize,
      changed: :name, on: :update,
      when: :codename_list_exist? do
  list_fields.each do |card|
    card.update_listed_by_cache_for card.item_keys
  end
  listed_by_fields.each &:update_cached_list
end

event :cardtype_of_list_item_changed, :validate,
      changed: :type, on: :save,
      when: :codename_list_exist? do
  linker_lists.each do |card|
    next unless card.item_type_id != type_id
    errors.add(:type,
               "can't be changed because #{name} " \
               "is referenced by list card #{card.name}")
  end
end
