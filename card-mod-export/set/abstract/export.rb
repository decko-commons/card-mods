basket[:filter_buttons] << :export_button

format do
  def export_filename
    "#{export_timestamp}-#{export_title}"
  end

  def export_title
    card.name.url_key
  end

  def export_timestamp
    Time.now.utc.strftime "%Y_%m_%d_%H%M%S"
  end

  def show_as_attachment
    return unless controller&.response && Cardio.config.export_disposition == :attachment

    controller.response.headers["Content-Disposition"] =
      "attachment; filename=\"#{export_filename}.#{format_ext}\""
  end
end

format :csv do
  def format_ext
    "csv"
  end

  def show *_args
    show_as_attachment
    super
  end
end

format :data do
  def show *_args
    show_as_attachment
    super
  end
end

format :json do
  def format_ext
    "json"
  end
end

format :html do
  def export_formats
    %i[csv json]
  end

  # don't cache because many export links include filter/sort params
  view :export_links, cache: :never do
    return "" if export_formats.blank?

    wrap_with :div, class: "export-links py-3" do
      "Export: #{export_format_links}"
    end
  end

  # view :filtered_results_footer do
  #   try(:no_results?) ? "" : render_export_button
  # end

  def export_format_links
    export_formats.map { |format| export_format_link format }.join " / "
  end

  def export_format_link format
    link_to_card card, format, path: export_link_path_args(format)
  end

  def default_export_link_path
    path export_link_path_args(default_export_format)
  end

  def default_export_format
    export_formats.first
  end

  def export_link_path_args format
    { format: format }
  end
end
