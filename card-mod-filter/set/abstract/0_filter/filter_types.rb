format :html do
  def select_filter field, default=nil, options=nil
    options = filter_options options
    options = [["--", ""]] + options unless default
    select_filter_tag field, default, options
  end

  def multi_filter field, default=nil, options=nil
    options ||= filter_options field
    multiselect_filter_tag field, default, options
  end

  def text_filter field, default=nil, opts=nil
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

  def multiselect_filter_tag field, default, options, html_options={}
    html_options[:multiple] = true
    select_filter_tag field, default, options, html_options
  end

  def select_filter_tag field, default, options, html_options={}
    name = filter_input_name field, html_options[:multiple]
    options = options_for_select options, (filter_param(field) || default)
    normalize_select_filter_tag_html_options field, html_options
    select_tag name, options, html_options
  end

  # alters html_options hash
  def normalize_select_filter_tag_html_options field, html_options
    pointer_suffix = html_options[:multiple] ? "multiselect" : "select"
    add_class html_options, "pointer-#{pointer_suffix} filter-input #{field} " \
                            "_filter_input_field _no-select2 form-control"
    # _no-select2 because select is initiated after filter is opened.
    html_options[:id] = "filter-input-#{unique_id}"
  end
end