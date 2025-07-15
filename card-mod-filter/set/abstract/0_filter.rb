include_set Abstract::BsBadge

format do
  def filter_cql_class
    Card::FilterCql
  end

  # definitive list of available filters
  # (see README)
  # For override (default value is name filtering only)
  # @return [Array<Hash>]
  def filter_map
    [{ key: :name, open: true }]
  end

  # current filters and values
  def filter_keys_from_params
    filter_hash.keys.map(&:to_sym) - [:not_ids]
  end

  # For override (default values)
  def sort_options
    { "Alphabetical": :name, "Recently Added": :create }
  end

  # all filter keys in the order they were selected
  def all_filter_keys
    @all_filter_keys ||= filter_keys_from_params | filter_keys
  end

  def current_sort
    sort_param || try(:default_sort_option)
  end

  def filter_param field
    filter_hash[field.to_sym]
  end

  # current filters in key value pairs
  def filter_hash
    @filter_hash ||=
      filter_hash_from_params ||
      voo.filter ||
      (Env.params[:refilter].present? ? {} : default_filter_hash)
  end

  def filter_hash_from_params
    param = Env.params[:filter]
    if param.blank?
      nil
    elsif param.to_s == "empty"
      {}
    else
      Env.hash(param).deep_symbolize_keys
    end
  end

  def sort_param
    @sort_param ||= valid_sort_param(:sort_by)
  end

  # list of keys of available filters
  def filter_keys
    filter_keys_from_map_list(filter_map).flatten.compact
  end

  def filter_keys_with_values
    filter_keys.map do |key|
      values = filter_param(key)
      values.present? ? [key, values] : next
    end.compact
  end

  # initial values for filtered search
  def default_filter_hash
    {}
  end

  def extra_paging_path_args
    super.merge filter_and_sort_hash
  end

  def filter_and_sort_hash
    { filter: filter_hash }.tap do |hash|
      hash[:sort_by] = sort_param if sort_param
    end
  end

  # helper method
  def filter_map_without_keys map, *keys
    map.reject do |item|
      item_key = item.is_a?(Hash) ? item[:key] : item
      item_key.in? keys
    end
  end

  private

  def valid_sort_param key
    return unless (param = params[key]).present?

    param = param.to_sym
    param if param.in? valid_sort_options
  end

  def valid_sort_options
    sort_options.values
  end

  def user_friendly_value value
    case value
    when Symbol
      value.cardname
    when String
      user_friendly_string_value value
    else
      value
    end
  end

  def user_friendly_string_value value
    value.starts_with?(/~|:/) ? value.cardname : value
  end

  def filter_keys_from_map_list list
    list.map do |item|
      case item
      when Symbol then item
      when Hash then filter_keys_from_map_hash item
      end
    end
  end

  def filter_keys_from_map_hash item
    item[:filters] ? filter_keys_from_map_list(item[:filters]) : item[:key]
  end
end
