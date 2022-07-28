format :html do
  delegate :import_item_class, :import_manager, :auto_add_type?, to: :card

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

  def export_link type
    link_to_card card, "csv",
                 path: { format: :csv, view: :export, map_type: type }
  end

  def item_checkbox
    check_box_tag "_import-map-item-checkbox"
  end

  def inline_suggestions_url type, name
    card_url path(suggest_path_args(type, :import_suggestions, name))
  end

  def suggest_link type, name
    modal_link '<i class="fa fa-search"></i>',
               # size: :large,
               title: "Search for #{type}",
               class: "btn btn-sm btn-outline-secondary " \
                      "_suggest-link _selectable-filter-link",
               path: suggest_path_args(type, :selectable_filtered_content, name)
  end

  def suggest_path_args type, view, name
    { view: view,
      mark: suggestion_filter_mark(type),
      slot: { items: { view: item_view(type) } },
      filter: suggestion_filter(type, name) }
  end

  def suggestion_filter_mark type
    @suggestion_filter_mark = import_item_class.try(:suggestion_mark, type) || type
  end

  def suggestion_filter type, name
    method = "#{type}_suggestion_filter"
    return { name: name } unless import_item_class.respond_to? method

    import_item_class.send method, name, import_manager
  end
end
