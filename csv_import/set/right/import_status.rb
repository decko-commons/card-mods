# content is JSON


# rows: [ { rownum: [status, id, ]


# key = status group
# value = [context, label(, statuses)]
STATUS_GROUPS = {
  failed: [:danger, "Error"],
  not_ready: [:context, "Not Ready"],
  ready: [:info, "Ready"],
  success: [:success, "Success", %i[imported overridden]]
}.freeze

def followable?
  false
end

def history?
  false
end

def status
  @status ||= ImportManager::Status.new content_hash
end

def content_hash
  JSON.parse content
end

def step key
  import_counts.step key
  save_status
end

def save_status
  update content: status.to_json
end

def generate!
  vm = validation_manager
  vm.validate
  self.content = vm.status.to_json
end

def corrections
  left.import_map_card.content_hash
end

def validation_manager
  @vm ||= ValidationManager.new left.csv_file, corrections: corrections
end

format :html do
  delegate :status, to: :card
  delegate :percentage, :count, to: :status

  # def wrap_data _slot=true
  #   super.merge "refresh-url" => path(view: @slot_view)
  # end
#
  # def wrap_classes slot
  #   class_up "card-slot", "_refresh-timer" if auto_refresh?
  #   super
  # end

  view :core, cache: :never do
    # with_header(progress_header, level: 4) do
      _render_progress_bar
    #end # + wrap_with(:p, undo_button) + wrap_with(:p, report)
  end

  view :progress_bar, cache: :never, unknown: true do
    sections = %i[imported skipped overridden failed].map do |type|
      progress_section type
    end.compact
    progress_bar(*sections)
  end

  view :compact, cache: :never, template: :haml

  def report
    [:failed, :skipped, :overridden, :imported].map do |key|
      next unless status[key].present?
      generate_report_alert key
    end.compact.join
  end


end
