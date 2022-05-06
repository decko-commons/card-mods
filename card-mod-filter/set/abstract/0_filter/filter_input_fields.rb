format :html do
  COMPACT_FILTER_TYPES = { radio: :select, check: :multiselect }

  def filter_input_field field, default: nil, compact: false
    fc = filter_config field
    default ||= fc[:default]
    filter_type = compact && COMPACT_FILTER_TYPES[fc[:type]] || fc[:type]
    send "#{filter_type}_filter", field, default, fc[:options]
  end

  private

  def select_filter field, default, options, multiple: false
    options = filter_options options
    options = [["--", ""]] + options unless default
    select_filter_tag field, default, options, multiple
  end

  def multiselect_filter field, default, options
    select_filter field, default, options, multiple: true
  end

  def select_filter_tag field, default, options, multiple
    select_tag filter_input_name(field, multiple),
               options_for_select(options, (filter_param(field) || default)),
               id: "filter-input-#{unique_id}",
               multiple: multiple,
               class: "_filter_input_field _no-select2 form-control filter-input" \
                      "filter-input-#{field} pointer-#{ 'multi' if multiple }select"
                      # _no-select2 because select is initiated after filter is opened.
  end

  def text_filter field, default, opts
    opts ||= {}
    value = filter_param(field) || default
    text_filter_with_name_and_value filter_input_name(field), value, opts
  end

  def text_filter_with_name_and_value name, value, opts
    opts[:class] ||= "simple-text"
    add_class opts, "form-control"
    text_field_tag name, value, opts
  end

  def range_filter field, default={}, opts=nil
    opts ||= {}
    add_class opts, "simple-text range-filter-field"
    default ||= {}
    output [range_sign(:from),
            sub_text_filter(field, :from, default, opts),
            range_sign(:to),
            sub_text_filter(field, :to, default, opts)]
  end

  def range_sign side
    dir = side == :from ? "right" : "left"
    fa_icon("chevron-circle-#{dir}", class: "input-group-text")
  end

  def sub_text_filter field, subfield, default={}, opts={}
    name = "filter[#{field}][#{subfield}]"
    value = filter_hash.dig(field, subfield) || default[subfield]
    text_filter_with_name_and_value name, value, opts
  end

  def autocomplete_filter type_code, _default, options_card=nil
    options_card ||= Card::Name[type_code, :type, :by_name]
    text_filter type_code, "", class: "#{type_code}_autocomplete",
                "data-options-card": options_card
  end

  def filter_input_name field, multi=false
    "filter[#{field}]#{'[]' if multi}"
  end
end