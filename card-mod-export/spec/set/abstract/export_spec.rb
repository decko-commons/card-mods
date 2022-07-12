RSpec.describe Card::Set::Abstract::Export do
  def card_subject
    "Cards with accounts".card.with_set(described_class)
  end

  check_html_views_for_errors
end
