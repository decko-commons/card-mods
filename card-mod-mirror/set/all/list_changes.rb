# -*- encoding : utf-8 -*-

event :preserve_mirrors, :validate,
      on: :update, changed: :type_id, when: :is_item_in_mirror? do
  errors.add :type, "cannot change type of item in mirrors: #{items_in_mirrors.join ', '}"
end

def items_in_mirrors
  @items_in_mirrors ||=
    Card.search left: name, type_id: [MirrorListID, MirroredListID], return: :name
end

def is_item_in_mirror?
  items_in_mirrors.present?
end
