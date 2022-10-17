include_set Abstract::Export
include_set Abstract::ProgressBar

format :html do
  delegate :status, :csv_file, :import_item_class, :mapping, to: :card
  delegate :percentage, :count, to: :status

  def tab_list
    STATUS_GROUPS.keys
  end

  def tab_options
    STATUS_GROUPS.each_with_object({}) do |(k, v), h|
      h[k] =  { label: v[1], count: count(k) }
    end
  end

  def default_tab
    tab_from_params || first_group_with_rows
  end

  def first_group_with_rows
    STATUS_GROUPS.keys.find { |status| count(status).positive? }
  end

  view :failed_tab do
    import_form :failed
  end

  view :not_ready_tab do
    main_content :not_ready
  end

  view :importing_tab do
    card_form(:update) { haml :importing_tab }
  end

  view :ready_tab do
    import_form :ready
  end

  view :success_tab do
    main_content :success
  end

  view :core, cache: :never, template: :haml

  view :progress_bar, cache: :never, unknown: true do
    sections = STATUS_GROUPS.map do |group, config|
      progress_section group, config
    end.compact
    progress_bar(*sections)
  end

  def main_content status
    @current_status = status
    table(status) + render_export_links
  end

  def import_form status
    card.left.format.card_form :update, success: { mark: card.name } do
      haml :import_form, status: status
    end
  end

  def export_formats
    [:csv]
  end

  def export_link_path_args format
    path = super
    path[:status] = @current_status if @current_status
    path
  end

  def progress_section group, config
    return if count(group).zero?
    context = config[0]
    label = config[1]
    html_class = "bg-#{context}"
    # html_class << " progress-bar-striped progress-bar-animated" if importing?
    { value: percentage(group), label: "#{count(group)} #{label}", class: html_class }
  end

  view :compact, cache: :never, template: :haml

  view :refresh do
    link_to icon_tag(:refresh),
            path: "#", class: "_import-status-refresh import-status-refresh"
  end
end

format :csv do
  view :titles do
    card.import_item_class.export_csv_header
  end

  view :core do
    csv_lines_for(params[:status]&.to_sym)
  end

  def csv_lines_for status
    lines = []
    card.each_item_with_status(status) do |_index, item|
      lines << item.export_csv_line(status)
    end
    lines
  end
end
