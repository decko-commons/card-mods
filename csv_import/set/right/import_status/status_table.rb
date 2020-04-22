format :html do
  LEFT_CELL = { ready: :checkbox, failed: :checkbox }.freeze

  def table status
    wrap do
      haml :table, status: status, columns: table_columns(status)
    end
  end

  def table_columns status
    columns = [(LEFT_CELL[status] || :row)]
    columns << :exists unless status == :not_ready
    columns << :errors if %i[failed not_ready].include?(status)
    columns += import_item_class.column_keys
    columns
  end

  def import_column? column
    column.in? import_item_class.column_keys
  end

  def column_title column
    import_column?(column) ? import_item_class.header(column) : column.to_s.capitalize
  end

  def each_row_with_status option
    import_manager.each_row(status.status_indeces(option)) do |item|
      yield item
    end
  end

  def each_cell columns, item
    columns.each do |col|
      ch = cell_hash col, item

      yield ch[:value], ch[:class], ch[:title]

    end
      # cell_title(column, val)
  end

  def import_manager
    card.left.import_manager
  end

  def cell_title column, val
    column.in?(import_item_class.column_keys) ? val : ""
  end

  def cell_hash column, item
    cell_type = import_column?(column) ? :import_content : :metadata
    send "#{cell_type}_cell_hash", column, item
  end

  def import_content_cell_hash column, item
    if (map = corrections[column])
      mappable_cell_hash map, column, item
    else
      val = item[column]
      { value: val, title: val }
    end
  end

  def metadata_cell_hash column, item
    { value: send("#{column}_value", item) }
  end

  def mappable_cell_hash map, column, item
    klass = "mapped-import-cell"
    raw = []
    styled = []
    item.value_array(column).each do |value|
      if mapped = map[value]
        raw << mapped
        styled << mapped_link(mapped)
      else
        klass = "unmapped-import-cell"
        raw << value
        styled << value
      end
    end
    { value: styled.join(", "), title: raw.join(", "), class: klass }
  end

  def mapped_link id, text=nil
    text ||= Card.fetch_name id
    modal_link text, path: { mark: id, view: :expanded_bar }
  end

  # def table_row_hash columns, hash, index
  #   columns.each_with_object({}) do |col, row_hash|
  #     row_hash[col] = hash.key?(col) ? hash[col] : send("#{col}_value", index)
  #   end
  # end

  def row_value item
    item.index + 1
  end

  def checkbox_value item
    check_box_tag("import_rows[#{item.index}]", true, false, class: "_import-row-checkbox") +
      " #{row_value item}"
  end

  def status_item index
    status.item_hash index
  end

  def exists_value item
    si = status_item item.index
    return unless (id = si[:id])
    mapped_link(id, icon_tag(:open_in_browser)) + conflict_note(si[:conflict])
  end

  def conflict_note conflict
    return "" unless conflict

    raw(" <small class=\"faint\">(#{conflict})</small>")
  end

  def errors_value item
    errors = status_item(item.index)[:errors]
    return unless errors.present?

    popover_link errors.join("\n"), # haml(:errors, errors: errors),
                 "#{errors.size} Errors",
                 labeled_badge(errors.size, nil, color: "danger")
  end
end