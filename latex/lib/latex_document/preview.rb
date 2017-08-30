module LatexDocument
  module Preview
    def preview_card
      Card.fetch "#{name}+preview", new: {:type=> Card::PlainTextID}
    end

    def pdf_preview_url filename=nil
      #filename ||= doc_basename
      #File.join '', 'tex', uuid[0..(Decko.config.tex_store_level-1)].chars.to_a, "#{filename}.pdf"
      preview_pdf_card = Card.fetch "#{name}+preview+pdf", :new => {:type_code => 'file'}
      preview_pdf_card.file.url
    end

    def new_preview_from_original
      if pdf_exists?
        new_typeset_uuid
        ensure_home
        FileUtils.cp(final_pdf_path, preview_pdf_path)
      else
        new_preview_from_default
      end
    end

    def new_preview_from_default
      new_typeset_uuid
      default = default_pdf_card
      if default
        ensure_home
        FileUtils.cp(default.file.path, final_pdf_path)
        FileUtils.cp(default.file.path, preview_pdf_path)
      else
        errors.add "Latex", "No default template #{default_pdf_cardname}."
      end
    end

    def typeset_preview content
      document_modified :content => content, :preview => true
    end

    def save_preview
      save_pdf
    end
  end
end
