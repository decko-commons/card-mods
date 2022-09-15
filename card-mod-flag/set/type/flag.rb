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

  # redirect to subject card after creation. hacky :(
  def card_form action, opts={}
    opts[:success] = { mark: card.subject_card.first_name } if action == :create
    super
  end

  view(:bar_left) { card.flag_type_card.first_name }
  view(:bar_right) { card.status }
  view :bar_bottom do
    field_nest :discussion, view: :titled, show: :comment_box
  end
end

# the following only matter if the flagged content uses lookups
def lookup_card
  subject_card&.first_card
end

def lookup
  lookup_card&.lookup
end

def lookup_columns
  [:open_flags]
end
