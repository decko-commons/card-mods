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
  import_status_card.update_items
end

event :disallow_content_update, :validate, on: :update, changed: :content do
  errors.add :permission_denied,
             "updates to import files are not allowed; " \
             "please create a new import file"
end

event :mark_items_as_importing, :validate, on: :update, when: :data_import? do
  item_indeces_from_params.each do |index|
    status.update_item index, status: :importing
  end
  import_status_card.save_status
end

event :initiate_import, :integrate, on: :update, when: :data_import? do
  return unless (indeces = item_indeces_from_params)&.size > 1
  indeces.each do |index|
    Env.with_params(import_rows: { index => true }) do
      import_item_with_delay
    end
  end
end

event :import_item, :integrate_with_delay, on: :update, when: :import_single_item? do
  # event :import_item, :integrate_with_delay, on: :update, when: :data_import? do
  import! item_indeces_from_params
end

def import_single_item?
  item_indeces_from_params&.size == 1
end

def import! item_indeces
  import_manager.each_item item_indeces do |index, import_item|
    Rails.logger.info "IMPORTING ITEM: #{import_item.input}"

    status = import_item.import
    import_status_card.status.update_item index, status
    Rails.logger.info "ITEM IMPORTED: #{status}"

    import_status_card.save_status
    Rails.logger.info "STATUS SAVED: #{status}"
  end
end

def data_import?
  Env.params[:import_rows].present?
end

def silent_change?
  data_import? || super
end

def item_indeces_from_params
  @item_indeces_from_params ||=
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
