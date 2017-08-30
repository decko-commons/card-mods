module LatexDocument
  module Paths
    BIB_PREFIX = 'bib_'
    TYPESET_PREFIX = 'ts_'
    def pdf_url
      pdf_card.file.url
      #File.join '', '/tex', uuid[0..(Decko.config.tex_store_level-1)].chars.to_a, "#{uuid}.pdf"
    end

    def home
      @home || @home = path_for_uuid
    end
    def bib_basename;      "#{BIB_PREFIX}#{uuid}"        end
    def doc_basename;      "#{TYPESET_PREFIX}#{typeset_uuid}"    end

    def bib_path
      File.join home, "#{bib_basename}.bib"
    end
    def tex_path
      File.join home, "#{doc_basename}.tex"
    end
    def log_path;          File.join home, "#{doc_basename}.log" end
    def aux_path;          File.join home, "#{doc_basename}.aux" end
    def pdf_path;          File.join home, "#{doc_basename}.pdf" end
    def preview_pdf_path;  File.join home, "#{doc_basename}.pdf" end
    def final_pdf_path;    File.join home, "#{uuid}.pdf"         end


    def fmt_path;  File.join TexCompiler.format_home, "#{format_name}.fmt" end
    def ini_path;  File.join TexCompiler.format_home, "#{format_name}.ini" end

    def create_uuid
      SecureRandom.uuid
    end

    def typeset_uuid
      @typeset_uuid || new_typeset_uuid
    end

    def new_typeset_uuid
      @typeset_uuid = create_uuid
    end

    def uuid
      return @uuid if @uuid

      hash = Card.fetch "#{name}-uuid"  # No plus card because it can be created while the tex card is created
      if not hash
        Card::Auth.as_bot do
          hash = Card.new(:name => "#{name}-uuid", :content => create_uuid)
          hash.save
        end
      end
      @uuid = hash.content
    end

    private

    def path_for_uuid
      File.join Decko.paths['tex'].first,
                uuid[0..(Decko.config.tex_store_level-1)].chars.to_a
    end
  end
end
