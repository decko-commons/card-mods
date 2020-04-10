format :html do
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
end