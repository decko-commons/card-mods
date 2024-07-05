FIELDS = %i[flag_type status subject discussion].freeze
REQUIRED_FIELDS = FIELDS - [:status]

card_accessor :flag_type, type: :pointer
card_accessor :subject, type: :pointer
card_accessor :status, type: :pointer # , default_content: "open"
card_accessor :discussion

REQUIRED_FIELDS.each { |fld| require_field fld }

format :html do
  # LOCALIZE
  before(:new) { voo.title = "Flag a problem" }
  before(:new_fields) { voo.buttons_view = :new_in_modal_buttons }

  def edit_fields
    card.new? ? REQUIRED_FIELDS : FIELDS
  end

  def new_form_opts
    super.merge "data-slotter-mode": "update-origin", class: "_close-modal"
  end

  mini_bar_cols 6, 6

  view :bar_left, template: :haml
  view(:bar_middle, wrap: :em) { field_nest :status, view: :core }
  view(:bar_right) { render_credit }
  view :bar_bottom do
    field_nest :discussion, view: :titled, show: :comment_box
  end

  view :credit do
    wrap_with :div, class: "credit text-muted" do
      ["Flagged", create_date, create_by_whom].join " "
    end
  end

  def create_date
    "#{render :updated_at} ago"
  end

  def create_by_whom
    "by #{link_to_card card.creator}"
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
