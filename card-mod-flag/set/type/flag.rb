FIELDS = %i[flag_type status subject discussion].freeze
REQUIRED_FIELDS = FIELDS - [:status]

def autoname?
  true
end

card_accessor :flag_type, type: :pointer
card_accessor :subject, type: :pointer
card_accessor :status, type: :pointer #, default_content: "open"
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
