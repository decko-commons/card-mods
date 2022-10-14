include_set Abstract::Tabs

delegate :import_manager, :import_item_class, :import_status_card,
         to: :left
delegate :column_hash, :mapped_column_keys, :suggest, :map_type, :map_types,
         to: :import_item_class
attr_writer :import_item_class

def followable?
  false
end

def history?
  false
end

# mapping of all uniq values in each mapped column (keys are strings)
# {
#   column1 => { val1 => card1.id,
#                val2 => card2.id,... },
#   column2 => { val3 => card3.id,... }, ...
# }
#
def map
  @map ||= content.present? ? parse_map(content) : {}
end

def parse_map map
  JSON.parse(map).symbolize_keys
end

event :update_import_mapping, :validate, on: :update, when: :mapping? do
  merge_mapping mapping_from_param
  self.content = map.to_json
end

event :update_import_status, :integrate_with_delay,
      priority: 8, on: :update, when: :mapping? do
  Director.clear
  @already_mapping = true
  auto_add_items
  status_card = import_status_card
  not_ready_items = status_card.status.status_indices :not_ready
  import_manager.each_item not_ready_items do |index, item|
    status_card.update_item_and_save index, item.validate!
  end
end

def auto_map!
  @map ||= {}
  auto_map_items
  self.content = @map.to_json
end

def auto_add_type? column
  import_item_class.auto_add_types.include? column
end

private

def auto_map_items
  import_manager.each_item do |_index, import_item|
    mapped_column_keys.each do |column|
      auto_map_item_vals import_item, column
    end
  end
end

def auto_map_item_vals import_item, column
  submap = map[map_type(column)] ||= {}
  import_item.value_array(column).each do |val|
    next if val.strip.blank? || submap.key?(val)

    submap[val] = import_item.map_field column, val
  end
end

def merge_mapping mapping
  mapping.each do |column, submap|
    column = column.to_sym
    normalize_submap column, submap
    map[column].merge! submap
  end
end

def normalize_submap type, submap
  submap.each do |name_in_file, cardname|
    submap[name_in_file] =
      if cardname.blank?
        nil
      else
        ImportMapItem.new(self, type, name_in_file, cardname).normalize
      end
  end
end

def mapping_from_param
  mapping = Env.hash(mapping_param).symbolize_keys
  mapping.values.each do |submap|
    submap.keys.each do |key|
      submap[CGI.unescape(key)] = submap.delete(key)
    end
  end
  mapping
end

def mapping_param
  Env.params[:mapping]
end

def mapping?
  mapping_param
end

def each_map_item
  map.each do |map_type, mapping|
    mapping.each do |name_in_file, cardname|
      yield ImportMapItem.new self, map_type, name_in_file, cardname
    end
  end
end

def auto_add_items
  each_map_item do |item|
    next unless item.auto_add?
    result = item.auto_add
    update_map item.type, item.name_in_file, result
  end
end

def update_map type, key, value
  map[type][key] = value
  self.content = map.to_json
  update_column :db_content, content
  expire
end
