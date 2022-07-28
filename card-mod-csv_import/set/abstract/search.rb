format :html do
  view :import_suggestions do
    output(import_suggestions_search.map { |item| import_suggestion item })
  end

  def import_suggestions_search
    Env.with_params(limit: 3) { search_with_params }
  end

  def import_suggestion item
    haml :import_suggestion, suggestion: item
  end
end
