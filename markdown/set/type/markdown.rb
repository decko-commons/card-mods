format :html do
  view :core do
    Maruku.new(card.content).to_html
  end

  def editor
    :ace_editor
  end

  def ace_mode
    :markdown
  end
end
