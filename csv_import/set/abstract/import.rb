card_accessor :import_status
card_accessor :imported_rows

delegate :mark_as_imported, :already_imported?, to: :imported_rows_card

def import_file?
  true
end

def csv_file
  # maybe we have to use file.read ?
  @csv_file ||= CsvFile.new attachment, csv_row_class, headers: :true
end

def clean_html?
  false
end

def csv_only? # for override
  true
end

event :validate_import_format_on_create, :validate,
      on: :create, when: :save_preliminary_upload? do
  validate_file_card upload_cache_card
end

event :validate_import_format, :validate,
      on: :update, when: :save_preliminary_upload? do
  validate_file_card self
end

def validate_file_card file_card
  if file_card.csv?
    validate_csv file_card
  elsif csv_only?
    abort :failure, "file must be CSV but was '#{file_card.attachment.content_type}'"
  end
end

def validate_csv file_card
  CsvFile.new file_card.attachment, csv_row_class, headers: :true
rescue CSV::MalformedCSVError => e
  abort :failure, "malformed csv: #{e.message}"
end

format :html do
  before :new do
    voo.help = help_text
    voo.show! :help
  end

  before :edit do
    voo.help = help_text
    voo.show! :help
  end

  def help_text
    rows = card.csv_row_class.columns.map { |s| s.to_s.humanize }
    "expected csv row format: #{rows.join ', '}"
  end

  def new_success
    { id: "_self", soft_redirect: false, redirect: true, view: :import }
  end

  def download_link
    handle_source do |source|
      %(<a href="#{source}" rel="nofollow">Download File</a><br />)
    end.html_safe
  end

  def import_link
    link_to "Import ...", path: { view: :import }, rel: "nofollow"
  end

  def last_import_status
    return unless card.import_status.present?
    link_to_card card.import_status_card, "Status of last import"
  end
end
