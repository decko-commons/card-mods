
STATUS_GROUPS = {
  ready: :ready,
  not_ready: :not_ready,
  failed: :failure,
  imported: :success,
  overridden: :success,
  skipped: :success
}

STATUS_HEADER = {
  failed: "Failed",
  imported: "Successfully created",
  overridden: "Overridden",
  skipped: "Skipped existing"
}.freeze

STATUS_CONTEXT = {
  failed: :danger,
  imported: :success,
  overridden: :warning,
  skipped: :info
}.freeze

def followable?
  false
end

def history?
  false
end

def status
  @status ||= ImportManager::Status.new content
end

def import_counts
  @import_counts ||= status[:counts]
end

def reset total
  @status = ImportManager::Status.new act_id: ActManager.act&.id, counts: { total: total }
  save_status
end

def step key
  import_counts.step key
  save_status
end

def save_status
  update content: status.to_json
end


format :html do
  delegate :status, :import_counts, to: :card
  delegate :percentage, :count, :step, to: :import_counts

  def wrap_data _slot=true
    super.merge "refresh-url" => path(view: @slot_view)
  end

  def wrap_classes slot
    class_up "card-slot", "_refresh-timer" if auto_refresh?
    super
  end

  def auto_refresh?
    @slot_view.in?([:open, :content, :titled]) && importing?
  end

  def importing?
    STATUS_CONTEXT.keys.inject(0) do |sum, key|
      sum + count(key)
    end < count(:total)
  end

  # returns plural if there are more than one card of type `count_type`
  def item_label count_type=nil
    label = card.left&.try(:item_label) || "card"
    count_type && count(count_type) > 1 ? label.pluralize : label
  end

  def item_count_label count_key
    label = item_label count_key
    "#{count(count_key)} #{label}"
  end

  def progress_header
    if importing?
      "Importing #{item_count_label :total} ..."
    elsif count(:overridden).positive?
      "#{item_count_label :imported} created and " \
      "#{item_count_label :overridden} updated" \
    else
      "Imported #{item_count_label(:imported)}"
    end
  end

  view :core, cache: :never do
    with_header(progress_header, level: 4) do
      _render_progress_bar
    end + wrap_with(:p, undo_button) + wrap_with(:p, report)
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
