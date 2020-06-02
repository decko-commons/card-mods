format :html do
  view :core do
    wrap { haml(:core) }
  end

  view :tabs, cache: :never do
    tabs tab_map
  end

  view :map_form do
    card_form :update, id: "mappingForm" do
      submit_button text: "Save Mappings", class: "_save-mapping"
    end
  end

  def item_view type
    item_view_hash[type] ||= card.left.try("import_map_#{type}_view") || :bar
  end

  def item_view_hash
    @item_view_hash ||= {}
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
    wrapped_tab_title title, total_badge(type, total)
  end

  def total_badge type, count
    tab_badge count, mapped_icon_tag(type), klass: "RIGHT-#{type.cardname.key}"
  end

  def export_link type
    link_to_card card, "csv",
                 path: { format: :csv, view: :export, map_type: type }
  end

  def map_ui type, name_in_file
    haml :map_ui, type: type, name_in_file: name_in_file
  end

  def suggest_link type, name, input_selector
    klass = card.import_item_class
    return unless (mark = klass.try "#{type}_suggestion_filter_mark")
    filter_key = klass.try("#{type}_suggestion_filter_key") || :name
    modal_link "Suggest",
               class: "btn btn-sm btn-secondary _suggest-link",
               path: { view: :selectable_filtered_content,
                       mark: mark,
                       slot: { hide: :full_page_link },
                       input_selector: input_selector,
                       filter: { filter_key => name } }
  end

  def map_action_dropdown map_type
    select_tag "import_map_action",
               options_for_select(action_hash(map_type)),
               class: "_import-map-action"
  end

  def action_hash map_type
    h = {"Select Action" => "", "Clear" => "clear" }
    h.merge!("Flag to AutoAdd" => "auto-add") if card.auto_add_type? map_type
    h
  end
end
