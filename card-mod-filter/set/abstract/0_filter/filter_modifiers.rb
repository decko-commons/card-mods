format :html do
  view :quick_filters, cache: :never, template: :haml
  view :filter_closers, cache: :never, template: :haml
  view :compact_quick_filters, cache: :never, template: :haml

  def removable_filters
    each_removable_filter do |key, value, array|
      array << [key, value, user_friendly_value(value)]
    end
  end

  # for override
  def active_quick_filter_class
    "btn btn-secondary"
  end

  # for override
  def inactive_quick_filter_class
    "btn btn-outline-secondary"
  end

  def quick_filter_items
    @quick_filter_items ||= quick_filter_list.map do |filter|
      quick_filter_item filter.clone
    end
  end

  private

  def each_removable_filter
    filter_hash&.each_with_object([]) do |(key, val), arr|
      next if val.blank? || filter_config(key)[:default] == val
      Array.wrap(val).each do |v|
        next if empty_filter_value_hash?(v) || quick_filter?(key, v)
        yield key, v, arr
      end
    end
  end

  def empty_filter_value_hash? value
    value.is_a?(Hash) && value.values.present? && !value.values.select(&:present?).any?
  end

  def quick_filter? key, value
    quick_filter_items.any? do |qf|
      qkey, qval = qf[:filter]
      qkey == key && value == Array.wrap(qval).first
    end
  end

  def quick_filter_item hash
    filter_key = hash.keys.first
    quick_filter_state do
      {
        text: (hash.delete(:text) || hash[filter_key]),
        icon: (hash.delete(:icon) || icon_tag(filter_key)),
        class: css_classes(hash.delete(:class),
                           "_quick-filter-link quick-filter-by-#{filter_key} "),
        filter:  normalize_quick_filter_item_value(hash)
      }
    end
  end

  def quick_filter_state
    yield.tap do |item|
      item[:class] <<
        if quick_filter_active? item[:filter]
          item[:active] = true
          active_quick_filter_class
        else
          inactive_quick_filter_class
        end
    end
  end

  def quick_filter_active? filter
    key, test_value = filter
    return false unless (active_value = filter_hash[key] || default_filter_hash[key])

    if active_value.is_a? Array
      active_value.include? Array.wrap(test_value).first
    else
      active_value == test_value
    end
  end

  def normalize_quick_filter_item_value filter
    filter = (filter[:filter] || filter).to_a.first
    key = filter.first
    value = filter.last
    value = value.to_s if value.is_a? Symbol
    value = Array.wrap(value) if filter_value_array? key
    [key, value]
  end
end
