format :html do
  delegate :status, :csv_file, :import_item_class, :corrections, to: :card
  delegate :percentage, :count, to: :status

  def tab_list
    STATUS_GROUPS.keys
  end

  def tab_options
    STATUS_GROUPS.each_with_object({}) do |(k, v), h|
      h[k] =  { label: v[1], count: count(k) }
    end
  end

  def column_title column
    Card::Codename.id(column) ? Card.fetch_name(column) : column.to_s.capitalize
  end

  def default_tab
    tab_from_params || :"#{first_group_with_rows}_tab"
  end

  def first_group_with_rows
    STATUS_GROUPS.keys.find { |status| count(status).positive? }
  end

  view :failed_tab do
    import_form(:failed) { table :failed }
  end

  view :not_ready_tab do
    table :not_ready
  end

  view :importing_tab do
    table :importing
  end

  view :ready_tab do
    import_form(:ready) { table :ready }
  end

  view :success_tab do
    table(:success)
  end

  view :core, cache: :never, template: :haml

  view :progress_bar, cache: :never, unknown: true do
    sections = STATUS_GROUPS.map do |group, config|
      progress_section group, config
    end.compact
    progress_bar(*sections)
  end

  def import_form status
    card.left.format.card_form :update, success: { mark: card.name } do
      haml :import_form, table: yield, status: status
    end
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
end
