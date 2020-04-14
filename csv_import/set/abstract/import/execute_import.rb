event :import_csv, :integrate_with_delay, on: :update, when: :data_import? do
  import! row_indeces_from_params
end

# event :allow_empty_import, :prepare_to_validate, on: :update, when: :data_import? do
#   @empty_ok = true
# end

def import! row_indeces
  import_manager.import_rows row_indeces do |_row|
    import_status_card.save_status status
  end
end

def import_manager
  @import_manager ||= ActImportManager.new self, csv_file,
                                           conflict_strategy: conflict_strategy,
                                           status: status,
                                           corrections: corrections
end

def conflict_strategy
  Env.params[:conflict_strategy]&.to_sym || :skip
end

def corrections
  import_map_card.map
end

def status
  @status ||= import_status_card.status
end

def data_import?
  Env.params[:import_rows].present?
end

def silent_change?
  data_import? || super
end

def row_indeces_from_params
  @row_indeces_from_params ||=
    Env.hash(:import_rows).each_with_object([]) do |(index, value), a|
      next unless [true, "true"].include?(value)
      a << index.to_i
    end
end
