format :html do
  def humanized_attachment_name
    "csv file"
  end

  def hidden_import_tags
    hidden_tags success: { name: card.import_status_card.name, view: :open }
  end

  view :import_button_formgroup do
    button_formgroup { [import_button, cancel_button(href: path)] }
  end

  def import_button
    button_tag "Import", class: "submit-button",
                         data: { disable_with: "Importing" }
  end
end
