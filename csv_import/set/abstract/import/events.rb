# CREATE EVENTS

event :validate_import_format_on_create, :validate, on: :create, when: :save_preliminary_upload? do
  validate_file_card upload_cache_card
end

event :generate_import_map, :finalize, on: :create do
  return unless import_item_class.mapped_column_keys.present?
  map = import_map_card
  map.auto_map!
  add_subcard map
end

event :generate_import_status, :finalize, after: :generate_import_map, on: :create do
  import_manager.validate
  import_status_card.save_status status
end

event :disallow_content_update, :validate, on: :update, changed: :content do
  errors.add :permission_denied,
             "updates to import files are not allowed; " \
             "please create a new import file"
end

event :mark_items_as_importing, :validate, on: :update, when: :data_import? do
  row_indeces_from_params.each do |index|
    status.update_item index, status: :importing
  end
  import_status_card.save_status
end

event :initiate_import, :integrate, on: :update, when: :data_import? do
  return unless (indeces = row_indeces_from_params)&.size > 1
  indeces.each do |index|
    Env.with_params(import_rows: { index => true }) do
      import_row_with_delay
    end
  end
end

event :import_row, :integrate_with_delay, on: :update, when: :import_single_row? do
  import! row_indeces_from_params
end

def import_single_row?
  row_indeces_from_params&.size == 1
end

def import! row_indeces
  import_manager.import row_indeces do |_row|
    # refresh seems inefficient, but without this it won't keep updating
    import_status_card.refresh(true).save_status status
    import_status_card.expire
  end
end

def data_import?
  Env.params[:import_rows].present?
end

def silent_change?
  data_import? || super
end

def row_indeces_from_params
  @row_indeces_from_params ||=
    Env.hash(Env.params[:import_rows]).select do |_k, v|
      [true, "true"].include?(v)
    end.keys.map(&:to_i)
end

def validate_file_card file_card
  if file_card.csv?
    validate_csv file_card
  elsif csv_only?
    abort :failure, "file must be CSV but was '#{file_card.attachment.content_type}'"
  end
end

def validate_csv file_card
  ImportCsv.new file_card.attachment, import_item_class, headers: true
rescue CSV::MalformedCSVError => e
  abort :failure, "Malformed CSV: #{e.message}"
rescue StandardError => e
  abort :failure, "CSV validation error: #{e.message}"
end
