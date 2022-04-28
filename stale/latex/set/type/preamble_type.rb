
event :typeset_preamble, :validate, :on=>:save do
  path = ::File.join TexCompiler.format_home, "#{self.key}.tex"
  ::File.write(path, content)
  # All cards using this documentclass
  unless Env.params[:ignore_errors]
    tex_cards = []
    Abstract::Latex::LATEX_TYPE_IDS.each do |latex_type|
      tex_cards += Card.search(type: latex_type).select { |c| c.preamble_cards.include? self }
    end

    # Die Formatdateien benutzen include für die Preambles. Deshalb muss die Format-Datei nicht angepasst werden
    tex_cards.uniq( &:format_name ).each do |c|
      begin
        if ::File.exist? c.ini_path
          c.tex_compiler.initex
        else
          c.generate_format
        end
      rescue TexTypesetError, TexConfigError => e
        errors.add "Latex", "Couldn't update format for #{c.name} with new preamble. #{e.message}"
        # FIXME: Undo changes
        return
      end
    end

    tex_cards.each do |tex_card|
      begin
        tex_card.preamble_modified
      rescue TexTypesetError, TexConfigError => e
        errors.add "Latex", "Couldn't typset #{c.name} with new preamble. #{e.message}"
        # FIXME: Undo changes
      end
    end
  end
  #old_content = Card.fetch( self.name ).content
  #File.open( File.join( TexCompiler.format_home, "#{self.key}.tex"), "w" ) { |f| f.puts old_content }
end

format :html do
  def editor
    :text_area
  end

  view :errors, mod: Abstract::Latex::HtmlFormat
  view :core do
    ::CodeRay.scan(_render_raw, :latex).div
  end
end
