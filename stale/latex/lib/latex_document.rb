# -*- encoding : utf-8 -*-

module LatexDocument
  PREPROCESS_RULES =
    { /\[\[\s*(http\:[^|\]]+)\s*\|\s*([^\]]+)\s*\]\]/ => '\href{http:\1}{\2}',
      /\[\[\s*([^|\]]+)\s*\|\s*([^\]]+)\s*\]\]/ => '\href{/\1}{\2}',   # Reference with link name
      /\[\[\s*(http\:[^\]]+)\s*\]\]/ => '\href{http:\1}{http:\1}',
      /\[\[\s*([^\]]+)\s*\]\]/ => '\href{/\1}{\1}',                    # Reference withouh link name
    }

  include Paths
  include Preview

  def pdf_exists?
    ensure_home
    File.exists?( final_pdf_path )
  end

  def tex_compiler
    @tex ||= TexCompiler.new self
  end

  def tex_template content  # no line breaks before content otherwise the line numbers for errors are wrong
    %{\\begin{document}\\title{Test} #{content.strip}
\\bibliography{#{bib_basename}}
\\bibliographystyle{apalike}
~\\end{document}
    }
  end

  def format_template docclasscard_content, includes
    %{#{docclasscard_content}
#{includes.map{|inc| "\\include{#{inc}}"}.join("\n")}
\\dump
    }
  end

  # Update methods
  def document_modified args = {}
    typeset_pdf args[:content]
    #if
    update_references_card
      generate_bibliography
      tex_compiler.pdflatex
      tex_compiler.pdflatex false
    #end
    save_pdf unless args[:preview]
  end

  # A bibitem used by this document was changed
  def bibitem_modified bibitem
    generate_bibliography
    typeset_pdf
    tex_compiler.pdflatex false # sencond run to get bibliography right, l
    save_pdf
  end

  def documentclass_modified
    typeset_pdf
    save_pdf
  end

  def preamble_modified
    typeset_pdf
    save_pdf
  end


  # Create new format file for new content of the documentclass
  def generate_format dc_card=nil, new_content=nil
    @docclass_card = dc_card if dc_card
    new_content ||= @docclass_card.content
    write_format_file new_content
    tex_compiler.initex
  end

  def generate_bibliography new_content=nil
    ensure_home
    write_bib_file new_content
    tex_compiler.bibtex
  end

  def default_tex_card
    Card.fetch(default_tex_cardname)
  end

  def default_pdf_card
    Card.fetch(default_pdf_cardname)
  end

  def default_pdf_cardname
    return "#{default_tex_cardname}+pdf"
  end

  def default_tex_cardname
    return "#{type_name} template"
  end

  def pdf_card
    Card.fetch "#{name}+pdf", :new => {:type_code => "file"}
  end

  def references_card
    Card.fetch  "#{name}+references", :new => {:type => "Pointer"}
  end

  def docclass_card
    return @docclass_card if @docclass_card

    docclass_cards = rule_card(:documentclass).item_cards
    case docclass_cards.size
    when 1
      return @docclass_card = docclass_cards.first
    when 0
      raise TexConfigError, "No documentclass defined."
    else
      raise TexConfigError, "More than one documentclass defined."
    end
  end

  def log_card
    Card.fetch log_cardname, new: {:type=>'PlainText'}
  end

  def log_cardname
    "#{name} log"
  end

  def preamble_cards
    rule_card(:preamble).item_cards
  end

  def preamble_keys
    @preamble_keys ||= rule_card(:preamble).item_cards.map(&:key)
  end

  def format_name  dc_card = docclass_card
    @format_name ||= dc_card.key + '_' + preamble_keys.join('_')
  end

  def update_pdf_card
    Card::Auth.as_bot do
      pdf_card.update_attributes :file => File.open("#{final_pdf_path}", "r")
    end
  end

  # Add all cited references in the tex document to the +References card
  def update_references_card
    ref_card = references_card
    old_bibitems = ref_card.item_names
    new_bibitems = get_cited_biblabels
    if old_bibitems.to_set == new_bibitems.to_set
      #errors.add(old_bibitems.join(' ')  + " ooooooo " + new_bibitems.join(' '))
      return false
    else
      Card::Auth.as_bot do
        ref_card.update_attributes content: new_bibitems.sort.to_pointer_content
      end
      return true
    end
  end

  def update_log_card new_content
    Card::Auth.as_bot do
      log_card.update_attributes :content => new_content
    end
  end

  private

  def typeset_pdf new_content=nil
    ensure_home
    ensure_bibfile
    ensure_fmtfile
    new_typeset_uuid
    write_typeset_file new_content || self.content
    tex_compiler.pdflatex
  end

  def save_pdf
    if File.exists? preview_pdf_path
      FileUtils.cp(preview_pdf_path, final_pdf_path)
      update_pdf_card
    end
  end

  def write_typeset_file new_content=nil
    file_content = preprocess( new_content || self.content )
    File.open( tex_path, "w" ) { |f| f.puts tex_template( file_content ) }
  end

  def write_format_file new_content=nil
    file_content = new_content || docclass_card.content
    File.open( ini_path, "w" ) { |f| f.puts format_template(file_content, preamble_keys) }
  end

  def write_bib_file new_content=nil
    file_content = new_content || references_card.item_names.map { |ref| Card.fetch( "#{ref}+bibtex", :new =>{} ).content }.join("\n\n")
    File.open( bib_path, "w" ) { |f| f.puts file_content }
  end

  def preprocess card_content
    # Links ersetzen
    PREPROCESS_RULES.each_pair do |ser, rep|
      card_content.gsub!( ser, rep )
    end
    return process_images card_content
  end

  def process_images card_content
    card_content.gsub(/\{\{\s*(\+?[^|{}]+)\|\s*path\s*\}\}/) do |m|
      image_card = Card.fetch $1.sub(/^\+/,"#{name}+"), :new => {:type => Card::ImageID }
      image_card.image.path
    end
  end

  # Create new format file if non-existent
  # Return path to format file (without ending) relative to tex document folder
  def ensure_fmtfile
    if not File.exists? fmt_path
      write_format_file
      tex_compiler.initex
    end
  end

  def ensure_bibfile
    File.open(bib_path, "w") {} unless File.exists? bib_path
  end

  def ensure_home
    FileUtils.mkpath home unless Dir.exists? home
  end

  def get_cited_biblabels
    labels = []
    if File.exists?(aux_path)
      File.open(aux_path) do |f|
        f.each_line do |line|
          /\\citation\{(?<label>[^}]+)\}/.match(line) { |m| labels << m[:label] }
        end
      end
    end
    labels.uniq
  end
end
