format do
  def filter_class
    Card::FilterQuery
  end

  def filter_map
    [:name]
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
    card.cql_content[:sort]
  end

  def filter_param field
    filter_hash[field.to_sym]
  end

  def filter_hash
    @filter_hash ||= filter_hash_from_params || default_filter_hash
  end

  def filter_hash_from_params
    return unless Env.params[:filter].present?

    Env.hash(Env.params[:filter]).deep_symbolize_keys
  end

  def sort_param
    @sort_param ||= safe_sql_param :sort
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

  def removable_filters
    filter_hash_from_params&.reject do |key, value|
      !value.present? || filter_config(key)[:default] == value
    end
  end

  def extra_paging_path_args
    super.merge filter_and_sort_hash
  end

  def filter_and_sort_hash
    { filter: filter_hash }.tap do |hash|
      hash[:sort] = sort_param if sort_param
    end
  end
end
