RSpec.describe Card::Set::Abstract::Import::Views do
  def card_subject
    "first test import".card
  end

  check_views_for_errors
  check_views_for_errors views: %i[new edit]
end
