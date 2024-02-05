# needs to be included here because Abstract::Search does not have Abstract::Filter
# when Abstract::CqlSearch includes Abstract::Search.
include_set Abstract::Filter

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
    filter_cql_class.new(filter_keys_with_values, blocked_id_cql).to_cql
  end

  def sort_cql
    { sort_by: current_sort }
  end

  def default_sort_option
    cql = card.cql_content || {}
    cql[:sort_by] || cql[:sort]
  end

  def blocked_id_cql
    not_ids = filter_param :not_ids
    not_ids.present? ? { id: ["not in", not_ids.split(",")] } : {}
  end
end
