include_set Abstract::FilteredBodyToggle

format :html do
  def filtered_body_views
    { bar_results: :bars, box_results: :boxes }
  end

  view :bar_results do
    voo.items[:view] = "bar"
    render_core
  end

  view :box_results do
    voo.items[:view] = "box"
    render_core
  end
end