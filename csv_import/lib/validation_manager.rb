# ValidateManager doesn't import anything. It is used for collecting invalid data
# to show it in the import table interface.
class ValidationManager < ImportManager
  def validate row_indices=nil
    validate_rows row_indices
    status.recount
  end

  def validate_rows row_indices
    #row_count = row_indices ? row_indices.size : @csv_file.row_count
    @csv_file.each_row self, row_indices do |csv_row|
      csv_row.validate!
    end
  end

  def add_card args
    handle_conflict args[:name], strategy: :skip_card do
      card = Card.new args
      card.validate
      pick_up_card_errors card
    end
  end
end
