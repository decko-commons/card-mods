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

  def each_cell columns, hash, index
    table_row_hash(columns, hash, index).each do |column, val|
      styled_val, klass = cell_value_and_class column, val
      yield styled_val, klass, cell_title(column, val)
    end
  end

  def cell_title column, val
    column.in?(import_item_class.column_keys) ? val : ""
  end

  def cell_value_and_class column, val
    if (map = corrections[column])
      mappable_cell_value_and_class map[val], val
    else
      [val, ""]
    end
  end

  def mappable_cell_value_and_class mapped, val
    if mapped
      [mapped_link(mapped), "mapped-import-cell"]
    else
      [val, "unmapped-import-cell"]
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

  def checkbox_value index
    check_box_tag("import_rows[#{index}]", true, false, class: "_import-row-checkbox") +
      " #{index + 1}"
  end

  def item index
    status.item_hash index
  end

  def exists_value index
    return unless (id = item(index)[:id])
    mapped_link(id, icon_tag(:open_in_browser)) + conflict_note(item(index)[:conflict])
  end

  def conflict_note conflict
    return "" unless conflict

    raw(" <small class=\"faint\">(#{conflict})</small>")
  end

  def errors_value index
    errors = item(index)[:errors]
    return unless errors.present?

    popover_link errors.join("\n"), # haml(:errors, errors: errors),
                 "#{errors.size} Errors",
                 labeled_badge(errors.size, nil, color: "danger")
  end
end