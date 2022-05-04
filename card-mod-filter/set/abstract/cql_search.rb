format do
  def search_params
    super.merge filter_and_sort_cql
  end

  def filter_and_sort_cql
    filter_cql.merge sort_cql
  end

  def filter_cql
    return {} if filter_hash.empty?

    filter_cql_from_params
  end

  # separate method is needed for tests
  def filter_cql_from_params
    filter_class.new(filter_keys_with_values, blocked_id_cql).to_cql
  end

  def sort_cql
    { sort: current_sort }
  end

  def blocked_id_cql
    not_ids = filter_param :not_ids
    not_ids.present? ? { id: ["not in", not_ids.split(",")] } : {}
  end
end
