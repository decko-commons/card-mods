require 'kramdown'

format :html do
  view :core do
    Kramdown::Document.new(card.content).to_html
  end

  def editor
    :ace_editor
  end

  def ace_mode
    :markdown
  end
end
