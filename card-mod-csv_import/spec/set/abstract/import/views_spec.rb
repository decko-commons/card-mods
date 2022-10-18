RSpec.describe Card::Set::Abstract::Import::Views do
  def card_subject
    "first test import".card
  end

  check_html_views_for_errors
  check_html_views_for_errors %i[new edit]
end
