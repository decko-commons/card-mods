format :html do
  before :new do
    voo.help = help_text
    voo.show! :help
  end

  before :edit do
    voo.help = help_text
    voo.show! :help
  end

  view :core do
    [field_nest(:import_map, view: :titled, title: "Mapping"),
     field_nest(:import_status, view: :titled, title: "Status")]
  end

  def help_text
    headers = card.import_item_class.headers
    "expected import item format: #{headers.join ', '}"
  end

  def download_link
    handle_source do |source|
      %(<a href="#{source}" rel="nofollow">Download File</a><br />)
    end.html_safe
  end

  view :bar_right do
    field_nest :import_status, view: :progress_bar
  end
end
