FIELDS = %i[flag_type status subject discussion].freeze
REQUIRED_FIELDS = FIELDS - [:status]

card_accessor :flag_type, type: :pointer
card_accessor :subject, type: :pointer
card_accessor :status, type: :pointer # , default_content: "open"
card_accessor :discussion

REQUIRED_FIELDS.each { |fld| require_field fld }

format :html do
  # LOCALIZE
  before :new do
    voo.title = "Flag a problem"
  end

  def edit_fields
    card.new? ? REQUIRED_FIELDS : FIELDS
  end
end

# the following only matter if the flagged content uses lookups
def lookup_card
  fetch(:subject)&.first_card
end

def lookup
  lookup_card&.lookup
end

def lookup_columns
  [:open_flags]
end
