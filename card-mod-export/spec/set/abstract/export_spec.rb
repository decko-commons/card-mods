RSpec.describe Card::Set::Abstract::Export do
  def card_subject
    "Sample Search".card
  end

  check_html_views_for_errors
end
