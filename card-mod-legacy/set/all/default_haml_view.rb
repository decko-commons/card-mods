format :html do
  def default_nest_view
    card.rule(:default_html_view) || super
  end
end
