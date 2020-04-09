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
  # def wrap_data _slot=true
  #   super.merge "refresh-url" => path(view: @slot_view)
  # end
  #
  # def wrap_classes slot
  #   class_up "card-slot", "_refresh-timer" if auto_refresh?
  #   super
  # end
  #
  def default_tab
    :"#{first_group_with_rows}_tab"
  end

  def first_group_with_rows
    STATUS_GROUPS.keys.find { |status| count(status).positive? }
  end

  def each_row_with_status option
    csv_file.selected_rows(status.status_indeces(option)) do |hash, index|
      yield hash, index
    end
  end

  view :failed_tab do
    table :failed
  end

  view :not_ready_tab do
    table :not_ready
  end

  view :ready_tab do
    table :ready
  end

  view :success_tab do
    table(:imported) + table(:overridden)
  end

  def table status
    wrap do
      haml :table, status: status, columns: table_columns(status)
    end
  end

  def table_columns status
    columns = [:row]
    columns << :exists unless status == :not_ready
    columns << :errors if status == :failed
    columns += import_item_class.column_keys
    columns
  end

  def each_cell columns, hash, index
    table_row_hash(columns, hash, index).each do |column, val|
      val, klass = cell_mapping column, val
      yield val, klass
    end
  end

  def cell_mapping column, val
    if (map = corrections[column])
      if mapped = map[val]
        [mapped_link(mapped), "mapped-import-cell"]
      else
        [val, "unmapped-import-cell"]
      end
    else
      [val, ""]
    end
  end

  def mapped_link id, text=nil
    text ||= Card.fetch_name id
    modal_link text, path: { mark: id, view: :expanded_bar }
  end

  def table_row_hash columns, hash, index
    columns.each_with_object({}) do |col, row_hash|
      row_hash[col] = hash.key?(col) ? hash[col] : send("#{col}_value", index)
    end
  end

  def row_value index
    index + 1
  end

  def exists_value index
    return unless (id = status.item_hash(index)[:id])
    mapped_link id, icon_tag(:open_in_browser)
  end

  def errors_value index
    errors = status.item_hash(index)["errors"]
    return unless errors.present?

    popover_link errors.join("\n"), # haml(:errors, errors: errors),
                 "#{errors.size} Errors",
                 labeled_badge(errors.size, nil, color: "danger")
  end

  view :core, cache: :never, template: :haml

  view :progress_bar, cache: :never, unknown: true do
    sections = STATUS_GROUPS.map do |group, config|
      progress_section group, config
    end.compact
    progress_bar(*sections)
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
