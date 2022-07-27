format :html do
  view :import_suggestions do
    Env.with_params(limit: 3) do
      output(search_with_params.map do |item|
        import_suggestion item
      end)
    end
  end

  def import_suggestion item
    haml :import_suggestion, suggestion: item
  end
end
