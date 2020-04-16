# content is JSON version of {ImportManager::Status} hash

include_set Abstract::Tabs

# key = status group
# value = [context, label]
STATUS_GROUPS = {
  not_ready: [:warning, "Not Ready"],
  ready: [:info, "Ready"],
  importing: [:secondary, "Importing"],
  failed: [:danger, "Failure"],
  success: [:success, "Success"]
}.freeze

delegate :csv_file, :import_item_class, :corrections, to: :left

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

def generate!
  im = import_manager
  im.validate
  self.content = im.status.to_json
end

