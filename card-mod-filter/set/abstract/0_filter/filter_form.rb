format :html do
  view :filter_bars, cache: :never, template: :haml

  # ~~~~ Compact (inline) sort and filter ui
  # including prototypes, filters, sorting, "More", and reset

  view :compact_filter_form, cache: :never, template: :haml
  view :filter_sort_dropdown, cache: :never, template: :haml
  view :compact_quick_filters, cache: :never, template: :haml

  # ~~~~ FILTER RESULTS

  view :filtered_content do
    wrap true, class: "_filtered-content nodblclick" do
      [render_offcanvas_filters, render_filtered_results(home_view: :filtered_results)]
    end
  end

  view :compact_filtered_content do
    wrap true, class: "_filtered-content nodblclick" do
      [render_compact_filter_form, render_filtered_results(home_view: :filtered_results)]
    end
  end

  view :filtered_results, cache: :never do
    wrap true, class: "_filter-result-slot" do
      [render_filtered_results_header, render_core, render_filtered_results_footer]
    end
  end

  view :offcanvas_filters, template: :haml, cache: :never
  view :filtered_results_header, template: :haml, cache: :never
  view :filtered_results_stats, cache: :never do
    labeled_badge count_with_params, "results"
  end

  # for override
  view(:filtered_results_footer) { "" }

  view :selectable_filtered_content, template: :haml, cache: :never

  before(:select_item) { class_up "card-slot", "_filter-result-slot" }
  view :select_item, cache: :never, wrap: :slot, template: :haml

  def filter_form_args
    {
      action: path,
      class: "slotter",
      method: "get",
      "accept-charset": "UTF-8",
      "data-remote": true,
      "data-slot-selector": "._filter-result-slot"
    }
  end

  def compact_filter_form_fields
    @compact_filter_form_fileds ||=
      all_filter_keys.map do |key|
        { key: key,
          label: filter_label(key),
          input_field: filter_input_field(key, compact: true),
          active: active_filter?(key) }
      end
  end

  def filter_bar item
    item = { key: item } unless item.is_a? Hash
    body = filter_bar_content item
    title = filter_label item[:key]
    accordion_item title, body: body, open: item[:open]
  end

  def filter_bar_content item
    if item[:type] == :group
      accordion do
        item[:filters].map do |subitem|
          filter_bar subitem
        end.join
      end
    else
      filter_input_field item[:key]
    end
  end

  def offcanvas_filter_id
    "#{card.name.safe_key}-offCanvasFilters"
  end

  def reset_filter_data
    JSON default_filter_hash
  end

  def quick_filter_item hash, filter_key
    {
      text: (hash.delete(:text) || hash[filter_key]),
      class: css_classes(hash.delete(:class),
                         "_compact-filter-link quick-filter-by-#{filter_key}"),
      filter: JSON(hash[:filter] || hash)
    }
  end

  # for override
  def quick_filter_list
    []
  end

  # for override
  def custom_quick_filters
    ""
  end

  def active_filter? field
    if filter_keys_from_params.present?
      filter_hash.key? field
    else
      default_filter_hash.key? field
    end
  end
end
