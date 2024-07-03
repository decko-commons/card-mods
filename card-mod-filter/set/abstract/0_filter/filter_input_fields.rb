format :html do
  COMPACT_FILTER_TYPES = { radio: :select, check: :multiselect }.freeze

  def filter_input_field field, default: nil, compact: false
    fc = filter_config field
    default ||= fc[:default]
    filter_type = (compact && COMPACT_FILTER_TYPES[fc[:type]]) || fc[:type] || :text
    send "#{filter_type}_filter", field, default, fc[:options]
  end

  private

  # ~~~~~~~ FILTER TYPES ~~~~~~~~~~~~~~~ #

  def check_filter *args
    check_or_radio_filter :check, *args
  end

  def radio_filter *args
    check_or_radio_filter :radio, *args
  end

  def select_filter field, default, options, multiple: false, view: :name
    options = filter_options options, field
    data = {}

    if options.is_a? String
      data = { "options-card": options }
      options = Array.wrap(filter_param(field)).map do |val|
        select_filter_option val, view
      end
    else
      options = [["--", ""]] + options unless default
    end
    select_filter_tag field, default, options, multiple: multiple, data: data
  end

  def multiselect_filter field, default, options
    select_filter field, default, options, multiple: true
  end

  def select_filter_option value, view
    display = view == :name ? value.cardname : nest(value, view)
    [display, value]
  end

  # def autocomplete_filter field, default, options_cardname
  #   options_cardname ||= [field, :type, :by_name].cardname
  #   select_filter field, default, [],
  #                 multiple: true,
  #                 data: { "options-card": options_cardname.cardname.url_key }
  #
  #   # options_card ||= Card::Name[type_code, :type, :by_name]
  #   # text_filter type_code, "", class: "#{type_code}_autocomplete",
  #   #                            "data-options-card": options_card
  # end

  def text_filter field, default, opts
    opts ||= {}
    value = filter_param(field) || default
    text_filter_with_name_and_value filter_input_name(field), value, opts
  end

  def range_filter field, default, opts
    opts ||= {}
    default ||= {}
    add_class opts, "simple-text range-filter-field"
    wrap_with :div, class: "input-group" do
      [range_sign(:from),
       sub_text_filter(field, :from, default, opts),
       range_sign(:to),
       sub_text_filter(field, :to, default, opts)]
    end
  end

  # ~~~~~~~ HELPER METHODS ~~~~~~~~~~~~~~~ #

  def check_or_radio_filter check_or_radio, field, default, options
    haml :check_filter,
         field_type: check_or_radio,
         field: field,
         input_name: filter_input_name(field, multi: (check_or_radio == :check)),
         options: filter_options(options, field),
         default: Array.wrap(filter_param(field) || default)
  end

  def text_filter_with_name_and_value name, value, opts
    opts[:class] ||= "simple-text"
    add_class opts, "form-control _submit-after-typing"
    text_field_tag name, value, opts
  end

  def select_filter_tag field, default, options,
                        multiple: false, disabled: false, data: {}
    klasses = "_filter_input_field filter-input filter-input-#{field} " \
              "_submit-on-change form-control " \
              "pointer-#{'multi' if multiple}select"
    # not sure form-control does much here?
    klasses << " _no-select2" if @compact_filter_form # select2 initiated once active

    select_tag filter_input_name(field, multi: multiple),
               options_for_select(options, (filter_param(field) || default)),
               id: "filter-input-#{unique_id}",
               multiple: multiple,
               class: klasses,
               disabled: disabled,
               data: data
  end

  def range_sign side
    dir = side == :from ? "greater" : "less"
    icon_tag("#{dir}_than", class: "input-group-text range-sign")
  end

  def sub_text_filter field, subfield, default={}, opts={}
    name = filter_input_name field, subfield: subfield
    value = filter_hash.dig(field, subfield) || default[subfield]
    text_filter_with_name_and_value name, value, opts
  end

  def filter_input_name field, subfield: nil, multi: false
    parts = [filter_prefix, "[#{field}]"]
    parts << "[#{subfield}]" if subfield
    parts << "[]" if multi
    parts.join
  end

  # for override
  def filter_prefix
    "filter"
  end
end
