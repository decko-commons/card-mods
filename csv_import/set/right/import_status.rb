# content is JSON version of {ImportManager::Status} hash

include_set Abstract::Tabs

# key = status group
# value = [context, label]
STATUS_GROUPS = {
  not_ready: [:secondary, "Not Ready"],
  ready: [:info, "Ready"],
  importing: [:warning, "Importing"],
  failed: [:danger, "Failure"],
  success: [:success, "Success"]
}.freeze

delegate :csv_file, :import_item_class, :corrections, :import_manager, to: :left

def status
  @status ||= ImportManager::Status.new content_hash
end

def followable?
  false
end

def history?
  false
end

def content_hash
  content.present? ? JSON.parse(content) : {}
end

def save_status status=nil
  update content: (status || self.status).to_json
end

def update_items indeces=nil
  import_manager.each_item(indeces) do |index, import_item|
    status.update_item index, import_item.validate!
  end
  save_status
end

def update_items_with_status status_option
  update_items status.status_indeces(status_option)
end

