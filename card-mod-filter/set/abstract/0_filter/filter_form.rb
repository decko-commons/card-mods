format :html do

  # offcanvas filter form + filtered results
  view :filtered_content, template: :haml, wrap: :slot


  view :overlay_filters do
    "hi mom"
  end

  view :filter_bars, cache: :never do
    filter_map.map do |item|
      if item.is_a?(Hash) && item[:type] == :group
        filter_bar_group item
      else
        filter_bar item
      end
    end
  end

  def filter_bar item
    item = item[:key] if item.is_a? Hash
    haml :filter_bar, item: item
  end

  def filter_bar_group item
    haml :filter_bar_group, item: item
  end


  # ~~~~ Compact (inline) sort and filter ui

  # filter form, including prototypes, filters, sorting, "More", and reset
  view :compact_filter_form, cache: :never, template: :haml
  view :compact_filter_sort_dropdown, cache: :never, template: :haml
  view :compact_quick_filters, cache: :never, template: :haml


  # view :overlay_filter_form, cache: :never, template: :haml

  # ~~~~ FILTER RESULTS

  view :filtered_results do
    class_up "card-slot", "_filter-result-slot"
    wrap do
      [
        render_filtered_results_header,
        render_core,
        render_filtered_results_footer
      ]
    end
  end

  view :filtered_results_header, template: :haml
  # for override
  view(:filtered_results_footer) { "" }

  view :open_filter_button, template: :haml
  view :selectable_filtered_content, template: :haml, cache: :never

  before(:select_item) { class_up "card-slot", "_filter-result-slot" }
  view :select_item, cache: :never, wrap: :slot, template: :haml

  def compact_filter_form_args
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
    @inline_filter_form_fileds ||=
      all_filter_keys.map do |key|
        { key: key,
          label: filter_label(key),
          input_field: filter_input_field(key),
          active: active_filter?(key) }
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
                         "_filter-link quick-filter-by-#{filter_key}"),
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
