include_set Abstract::Tabs

delegate :import_manager, to: :left
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

def import_item_class
  @import_item_class ||= left.import_item_class
end

event :update_import_mapping, :validate, on: :update, when: :mapping_param do
  merge_mapping mapping_from_param
  self.content = map.to_json
end

event :update_import_status, :finalize, on: :update, when: :mapping_param do
  status_card = left.import_status_card
  not_ready_items = status_card.status.status_indeces :not_ready
  left.import_manager.each_item not_ready_items do |index, item|
    status_card.status.update_item index, item.validate!
  end
  status_card.save_status
end

def auto_map!
  @map ||= {}
  auto_map_items
  self.content = @map.to_json
end

format :csv do
  view :export do
    raise Card::Error, "type required" unless (type = params[:map_type])

    lines = [["Name in File", "Name in WikiRate", "WikiRate ID"]]
    export_content_lines type, lines
    lines.map { |l| CSV.generate_line l }.join
  end

  def export_content_lines type, lines
    card.map[type.to_sym].map do |key, value|
      lines << [key, clean_value(value), value]
    end
  end

  def clean_value value
    value == "AutoAdd" ? value : value&.cardname
  end
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
  submap = @map[map_type(column)] ||= {}
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
    submap[name_in_file] = MapItem.new(self, type, cardname).normalize
  end
end

class MapItem
  attr_reader :map_card, :type, :cardname

  def initialize map_card, type, cardname
    @map_card = map_card
    @type = type
    @cardname = cardname
  end

  def normalize
    handling_auto_add do
      normalize_cardname do
        mapped_id || invalid_mapping
      end
    end
  rescue StandardError
    invalid_mapping
  end

  private

  # FIXME: could break if type and column have different names
  def mapped_id
    map_card.import_item_class.new(type => cardname).map_field type, cardname
  end

  def invalid_mapping
    map_card.errors.add :content, "invalid #{type} mapping: #{cardname}"
    nil
  end

  def handling_auto_add
    cardname == "AutoAdd" && auto_add_type? ? "AutoAdd" : yield
  end

  def normalize_cardname
    @cardname = Card::Env::Location.cardname_from_url(cardname) || cardname
    cardname.blank? ? nil : yield
  end

  def auto_add_type?
    map_card.auto_add_type? type
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
