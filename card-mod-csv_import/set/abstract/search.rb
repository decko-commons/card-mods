format :html do
  view :import_suggestions do
    results = Env.with_params(limit: 3) { import_suggestions_search }
    output(results.map { |item| import_suggestion item })
  end

  def import_suggestions_search
    search_with_params
  end

  def import_suggestion item
    haml :import_suggestion, suggestion: item
  end
end
