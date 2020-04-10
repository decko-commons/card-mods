# content is JSON version of {ImportManager::Status} hash

include_set Abstract::Tabs

# key = status group
# value = [context, label]
STATUS_GROUPS = {
  not_ready: [:warning, "Not Ready"],
  ready: [:info, "Ready"],
  failed: [:danger, "Failure"],
  success: [:success, "Success"]
}.freeze

delegate :csv_file, :import_item_class, to: :left

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
  JSON.parse content
end

def save_status
  update content: status.to_json
end

def generate!
  im = import_manager
  im.validate
  self.content = im.status.to_json
end

def corrections
  @corrections ||= left.import_map_card.map
end

def import_manager
  ImportManager.new csv_file, corrections: corrections
end
