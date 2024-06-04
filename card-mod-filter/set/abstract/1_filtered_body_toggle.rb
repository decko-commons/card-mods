format :html do
  view :filtered_results_nav do
    [render_filter_sort_dropdown, render_filtered_body_toggle]
  end

  view :filtered_body_toggle do
    wrap_with :div, class: "_filtered-body filtered-body ms-2" do
      filtered_body_views.map do |view, icon|
        link_to_filtered_body view, icon
      end
    end
  end

  def current_filtered_body
    params[:filtered_body] || default_filtered_body
  end

  def default_filtered_body

  end

  def filtered_body_views
    []
  end

  def link_to_filtered_body view, icon
    link_to icon_tag(icon),
            class: "_filtered-body-toggle btn ms-1",
            data: { view: view },
            href: "#"
  end

  def extra_paging_path_args
    super.merge filtered_body: current_filtered_body
  end
end