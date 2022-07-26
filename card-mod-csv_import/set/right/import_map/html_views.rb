format :html do
  delegate :auto_add_type?, to: :card

  STATUSES = {
    matched: "Match",
    suggested: "Pending",
    unmatched: "No Match"
  }.freeze

  ACTIONS = {
    create: "Create",
    accept: "Accept",
    reset: "Reset",
    hide: "Hide",
    showonly: "Show Only",
    show: "Show All"
  }.freeze

  view :core do
    wrap { haml(:core) }
  end

  view :tabs, cache: :never do
    tabs tab_map
  end

  view :map_form do
    card_form :update, id: "mappingForm" do
      submit_button text: "Save Changes", class: "_save-mapping"
    end
  end

  def selector_options
    { all: "All", none: "None" }.merge STATUSES
  end

  def action_options
    ACTIONS
  end

  def status_label status
    STATUSES[status]
  end

  def item_view type
    card.left.try("import_map_#{type}_view") || :bar
  end

  def tab_map
    card.map_types.each_with_object({}) do |type, tab|
      tab[type] = { content: map_table(type), title: tab_title(type) }
      tab
    end
  end

  def map_table type
    haml :map_table, map_type: type
  end

  def tab_title type
    map = card.map[type]
    total = map.keys.count
    unmapped = total - map.values.compact.count
    title = type.cardname.vary :plural
    title = "(#{unmapped}) #{title}" if unmapped.positive?
    super title, count: total, klass: "RIGHT-#{type.cardname.key}"
  end

  # def map_item name_in_file, cardid, type, item_view
  #   cardname = cardid&.cardname
  #   suggestions = cardname ? [] : map_item_suggestions(name_in_file)
  #   template = map_item_template cardname, suggestions
  #   haml template, name_in_file: name_in_file,
  #                  cardname: cardname,
  #                  item_view: item_view,
  #                  type: type,
  #                  suggestions: suggestions
  # end

  def map_item_status cardname, suggestions
    if cardname
      :matched
    elsif suggestions.present?
      :suggested
    else
      :unmatched
    end
  end

  def map_item_suggestions name_in_file
    []
  end

  def export_link type
    link_to_card card, "csv",
                 path: { format: :csv, view: :export, map_type: type }
  end

  def item_checkbox
    check_box_tag "_import-map-item-checkbox"
  end

  # def map_ui type, name_in_file
  #   haml :map_ui, type: type, name_in_file: name_in_file
  # end

  def suggest_link type, name
    klass = card.import_item_class
    return unless (mark = klass.try "#{type}_suggestion_filter_mark")
    filter_key = klass.try("#{type}_suggestion_filter_key") || :name
    modal_link '<i class="fa fa-search"></i>',
               size: :large,
               title: "Search for #{type}",
               class: "btn btn-sm btn-outline-secondary _suggest-link _selectable-filter-link",
               path: { view: :selectable_filtered_content,
                       mark: mark,
                       filter: { filter_key => name } }
  end

  # def map_action_dropdown map_type
  #   select_tag "import_map_action",
  #              options_for_select(action_hash(map_type)),
  #              class: "_import-map-action"
  # end
  #
  # def action_hash map_type
  #   h = {"Select Action" => "", "Clear" => "clear" }
  #   h.merge!("Flag to AutoAdd" => "auto-add") if card.auto_add_type? map_type
  #   h
  # end
end
