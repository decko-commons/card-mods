format :html do

  def pdf?
    (mime = card.file.content_type) && mime == "application/pdf"
  end

  def default_pdfjs_iframe_args args
    args[:pdf_url] ||= card.file.url
  end

  view :pdfjs_iframe do |args|
    <<-HTML
      <iframe id="source-preview-iframe"
              src="assets/web/viewer.html?file=#{args[:pdf_url]}"
              security="restricted"
              sandbox="allow-same-origin allow-scripts allow-forms" >
      </iframe>
    HTML
  end

  view :pdfjs_viewer do |args|

  end
end