basket[:list_input_options] << "prosemirror editor"
basket[:script_calls]["setProseMirrorConfig"] = :prosemirror_config

format :html do
  def prosemirror_config
    Card::Rule.global_setting :prose_mirror
  end

  def prosemirror_editor_input
    wrap_with :div, id: unique_id, class: "prosemirror-editor" do
      hidden_field :content, class: "d0-card-content", value: card.content
    end
  end
end
