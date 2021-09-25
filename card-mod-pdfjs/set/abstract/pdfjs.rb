format :html do
  def pdf?
    card.respond_to?(:file) && card.file.content_type == "application/pdf"
  end

  def default_pdfjs_iframe_args args
    args[:pdf_url] ||= card.file.url if card.respond_to?(:file)
    args[:viewer_path] ||= "/mod/pdfjs/web/viewer.html"
    args[:viewer_path] << "?file=#{args[:pdf_url]}" if args[:pdf_url]
  end

  def pdfjs_iframe args
    default_pdfjs_iframe_args args
    <<-HTML
      <iframe style="width: 100%"
              id="source-preview-iframe" class="pdfjs-iframe"
              src="#{args[:viewer_path]}"
              security="restricted"
              sandbox="allow-same-origin allow-scripts allow-forms allow-modals
                       allow-top-navigation"
              allowfullscreen>
      </iframe>
    HTML
  end

  view :pdfjs_viewer do
    # TODO: show pdfjs viewer directly without iframe
    # Pdfjs.viewer
  end
end
