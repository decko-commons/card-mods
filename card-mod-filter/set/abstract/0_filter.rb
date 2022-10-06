include_set Abstract::BsBadge

format do
  def filter_class
    Card::FilterQuery
  end

  def filter_map
    [{ key: :name, open: true }]
  end

  def filter_keys_from_params
    filter_hash.keys.map(&:to_sym) - [:not_ids]
  end

  def sort_options
    { "Alphabetical": :name, "Recently Added": :create }
  end

  # all filter keys in the order they were selected
  def all_filter_keys
    @all_filter_keys ||= filter_keys_from_params | filter_keys
  end

  def current_sort
    sort_param || default_sort_option
  end

  def default_sort_option
    cql = card.cql_content || {}
    cql[:sort_by] || cql[:sort]
  end

  def filter_param field
    filter_hash[field.to_sym]
  end

  def filter_hash
    @filter_hash ||= filter_hash_from_params || voo.filter || default_filter_hash
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
    @sort_param ||= safe_sql_param :sort_by
  end

  def safe_sql_param key
    param = Env.params[key]
    param.blank? ? nil : Card::Query.safe_sql(param)
  end

  def filter_keys
    filter_keys_from_map_list(filter_map).flatten.compact
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

  def filter_hash_without key, value
    filter_hash.clone.tap do |hash|
      case hash[key]
      when Array
        hash[key] = hash[key] - Array.wrap(value)
      else
        hash.delete key
      end
    end
  end

  def removable_filters
    each_removable_filter do |key, value, array|
      if value.is_a? Array
        value.each { |v| array << [key, v] }
      elsif !empty_filter_value_hash? value
        array << [key, value]
      end
    end
  end

  def empty_filter_value_hash? value
    value.is_a?(Hash) && value.values.present? && !value.values.select(&:present?).any?
  end

  def each_removable_filter
    filter_hash&.each_with_object([]) do |(key, val), arr|
      yield key, val, arr if val.present? && filter_config(key)[:default] != val
    end
  end

  def extra_paging_path_args
    super.merge filter_and_sort_hash
  end

  def filter_and_sort_hash
    { filter: filter_hash }.tap do |hash|
      hash[:sort_by] = sort_param if sort_param
    end
  end
end
