include_set Abstract::BsBadge

format :html do
  SHOW_CHECKBOX = { ready: true, failed: true }.freeze

  def table status
    wrap do
      haml :table, status: status, columns: import_item_class.column_keys
    end
  end

  def import_column? column
    column.in? import_item_class.column_keys
  end

  def column_title column
    import_column?(column) ? import_item_class.header(column) : column.to_s.capitalize
  end

  def each_cell columns, item
    columns.each do |col|
      ch = cell_hash col, item

      yield ch[:value], ch[:class], ch[:title]
    end
      # cell_title(column, val)
  end

  def cell_title column, val
    column.in?(import_item_class.column_keys) ? val : ""
  end

  def cell_hash column, item
    if (map = mapping[import_item_class.map_type(column)])
      mappable_cell_hash map, column, item
    else
      val = item[column]
      { value: val, title: val }
    end
  end

  def mappable_cell_hash map, column, item
    klass = "mapped-import-cell"
    raw = []
    styled = []
    item.value_array(column).each do |value|
      if mapped = map[value]
        raw << mapped
        styled << styled_value(value, mapped)
      else
        klass = "unmapped-import-attrib"
        raw << value
        styled << value
      end
    end
    { value: styled.join(", "), title: raw.join(", "), class: klass }
  end

  def styled_value value, mapped
    if mapped&.to_s&.match?(/^AutoAdd/)
      "<em>#{mapped} (#{value})</em>"
    else
      mapped_link mapped
    end
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

  def row_label_cell status, index
    output([
      (checkbox(index) if SHOW_CHECKBOX[status]),
      (index + 1),
      exists_value(index),
      errors_value(index)
    ].compact)
  end

  def checkbox index
    check_box_tag("import_rows[#{index}]", true, false,
                  class: "_import-row-checkbox")
  end

  def status_item index
    status.item_hash index
  end

  def exists_value index
    si = status_item index
    return unless (id = si[:id])
    mapped_link(id, icon_tag(:open_in_browser)) + conflict_note(si[:conflict])
  end

  def conflict_note conflict
    return "" unless conflict

    raw(" <small class=\"text-muted\">(#{conflict})</small>")
  end

  def errors_value index
    errors = status_item(index)[:errors]
    return unless errors.present?

    popover_link errors.join("\n"), # haml(:errors, errors: errors),
                 "#{errors.size} Errors",
                 labeled_badge(errors.size, nil, color: "danger")
  end
end