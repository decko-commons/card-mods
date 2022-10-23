format :html do
  def pdf?
    card.respond_to?(:file) && card.file.content_type == "application/pdf"
  end

  def default_pdfjs_iframe_args args
    args[:pdf_url] ||=
    args[:viewer_path] ||= card_path "/mod/pdfjs/web/viewer.html"

  end

  def pdfjs_iframe pdf_url: nil, viewer_path: nil
    pdf_url ||= pdf_url_from_card
    haml :pdfjs_iframe, viewer_path: pdf_viewer_path(viewer_path, pdf_url)
    <<-HTML

    HTML
  end

  view :pdf_preview do
    wrap_with :div, id: "pdf-preview" do
      pdfjs_iframe pdf_url: card.file_url
    end
  end

  view :pdfjs_viewer do
    # TODO: show pdfjs viewer directly without iframe
    # Pdfjs.viewer
  end

  private

  def pdf_url_from_card
    card.file.url if card.respond_to? :file
  end

  def pdf_viewer_path viewer_path, pdf_url
    viewer_path ||= card_path "/mod/pdfjs/web/viewer.html"
    viewer_path << "?file=#{pdf_url}" if pdf_url
    viewer_path
  end
end
