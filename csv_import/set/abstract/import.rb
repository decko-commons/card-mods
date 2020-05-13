include_set Type::File

card_accessor :import_status, type: :json
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

def import_manager
  @import_manager ||= ActImportManager.new self, csv_file,
                                           conflict_strategy: conflict_strategy,
                                           status: status,
                                           corrections: corrections
end

def conflict_strategy
  cs = Env.params[:conflict_strategy]
  cs ? cs.to_sym : :skip
end

def corrections
  import_map_card.map
end

def status
  @status ||= import_status_card.status
end
