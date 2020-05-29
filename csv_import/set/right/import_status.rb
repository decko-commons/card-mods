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

def reset status_option
  import_manager.validate(status.status_indeces status_option)
  save_status import_manager.status
end

def generate!
  import_manager.validate
  self.content = import_manager.status.to_json
end

def import_manager
  left.import_manager
end

def each_row_with_status option
  import_manager.each_row(status.status_indeces(option)) do |item|
    yield item
  end
end
