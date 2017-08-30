

event :typeset_documentclass, :validate, :on=>:save do
  # All cards using this documentclass
  unless Env.params[:ignore_errors]
    tex_cards = []
    Card::Set::Abstract::Latex::LATEX_TYPE_IDS.each do |latex_type|
      tex_cards += Card.search( type: latex_type ).select {|c| c.docclass_card == self}
    end
    tex_cards.uniq { |c| c.format_name(self) }.each do |tex_card|
      begin
        tex_card.generate_format self, content
      rescue TexTypesetError, TexConfigError => e
        errors.add "Latex", "Couldn't create format file for #{tex_card.name}. #{e.message}"
        #FIXME Undo changes
      end
    end
    tex_cards.each do |tex_card|
      begin
        tex_card.documentclass_modified
      rescue TexTypesetError, TexConfigError => e
        errors.add "Latex", "Couldn't typeset #{tex_card.name} with new documentclass. #{e.message}"
        #FIXME Undo changes
      end
    end
  end
end

format :html do
  def editor
    :text_area
  end

  view :errors, mod: Abstract::Latex::HtmlFormat
end
