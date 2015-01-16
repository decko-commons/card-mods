format :html do
  view :core do |args|
    Maruku.new(card.content).to_html
  end
  
  view :editor, :mod=>Type::PlainText::HtmlFormat
end