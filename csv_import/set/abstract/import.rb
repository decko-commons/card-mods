card_accessor :import_status
card_accessor :import_map, type: :json

def import_file?
  true
end

def csv_file
  # maybe we have to use file.read ?
  @csv_file ||= CsvFile.new attachment, import_item_class, headers: :true
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

event :disallow_content_update, :validate, on: :update, changed: :content do
  errors.add :permission_denied,
             "updates to import files are not allowed; " \
             "please create a new import file"
end

def validate_file_card file_card
  if file_card.csv?
    validate_csv file_card
  elsif csv_only?
    abort :failure, "file must be CSV but was '#{file_card.attachment.content_type}'"
  end
end

event :generate_import_map, :finalize, on: :create do
  return unless import_item_class.mapped_column_keys.present?
  map = import_map_card
  map.auto_map!
  add_subcard map
end

event :generate_import_status, :finalize, after: :generate_import_map, on: :create do
  stat = import_status_card
  stat.generate!
  add_subcard stat
end

def validate_csv file_card
  CsvFile.new file_card.attachment, import_item_class, headers: :true
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
    rows = card.import_item_class.column_keys.map { |s| s.to_s.humanize }
    "expected import item format: #{rows.join ', '}"
  end

  def download_link
    handle_source do |source|
      %(<a href="#{source}" rel="nofollow">Download File</a><br />)
    end.html_safe
  end
end
