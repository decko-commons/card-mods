format do
  def export_filename
    "#{export_timestamp}-#{export_title}"
  end

  def export_title
    card.name.url_key
  end

  def export_timestamp
    DateTime.now.utc.strftime "%Y_%m_%d_%H%M%S"
  end
end

format :data do
  def show *_args
    controller.response.headers["Content-Disposition"] =
      "attachment; filename=\"#{export_filename}\""
    super
  end
end

format :html do
  def export_formats
    [:csv, :json]
  end

  # don't cache because many export links include filter/sort params
  view :export_links, cache: :never do
    return "" if export_formats.blank?

    wrap_with :div, class: "export-links py-3" do
      "Export: #{export_format_links}"
    end
  end

  view :export_button, cache: :never, template: :haml

  view :export_panel, cache: :never, template: :haml

  view :filtered_results_footer do
    try(:no_results?) ? "" : render_export_button
  end

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

  def export_modal_link text, opts={}
    opts[:path] = { mark: card.name, view: :export_panel }
    modal_link text, opts
  end

  def export_link_path_args format
    { format: format }
  end

  # localize
  def export_item_limit_label
    type_name = item_type_name
    type_name.present? ? type_name&.vary(:plural) : "Items"
  end

  def export_limit_options
    options = [50, 100, 500, 1000, 5000].map { |num| ["up to #{num}", num] }
    options_for_select options,
                       disabled: (Auth.signed_in? ? [] : [1000, 5000]),
                       selected: (Auth.signed_in? ? 5000 : 500)
  end
end
