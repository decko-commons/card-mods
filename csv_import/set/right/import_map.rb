include_set Abstract::Tabs

delegate :import_manager, :import_item_class, to: :left
delegate :column_hash, :mapped_column_keys, :map_type, :map_types, to: :import_item_class
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

event :update_import_mapping, :validate, on: :update, when: :mapping_param do
  merge_mapping mapping_from_param
  self.content = map.to_json
end

event :update_import_status, :integrate, on: :update, when: :mapping_param do
  status_card = left.import_status_card
  not_ready_items = status_card.status.status_indeces :not_ready
  import_manager.each_item not_ready_items do |index, item|
    status_card.status.update_item index, item.validate!
  end
  status_card.save_status
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
      cardname.blank? ? nil : MapItem.new(self, type, name_in_file, cardname).normalize
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

class MapItem
  attr_reader :map_card, :type, :cardname, :name_in_file

  def initialize map_card, type, name_in_file, cardname
    @map_card = map_card
    @type = type
    @name_in_file = name_in_file
    @cardname = cardname
  end

  def normalize
    normalize_cardname do
      handling_auto_add do
        mapped_id || invalid_mapping
      end
    end
  rescue StandardError => e
    invalid_mapping e.message
  end

  private

  # FIXME: could break if type and column have different names
  def mapped_id
    map_card.import_item_class.new(type => cardname).map_field type, cardname
  end

  def invalid_mapping error=nil
    message = "invalid #{type} mapping: #{cardname}"
    message += " (#{error})" if error
    map_card.errors.add :content, message
    nil
  end

  def handling_auto_add
    cardname == "AutoAdd" && auto_add_type? ? auto_add : yield
  end

  def normalize_cardname
    @cardname = Card::Env::Location.cardname_from_url(cardname) || cardname
    cardname.blank? ? nil : yield
  end

  def auto_add_type?
    map_card.auto_add_type? type
  end

  def auto_add
    map_card.import_item_class.auto_add type, name_in_file
  end
end
