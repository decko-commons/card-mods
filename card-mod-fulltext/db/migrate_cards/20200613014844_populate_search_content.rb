
class PopulateSearchContent < Cardio::Migration
  def up
    Card.find_each do |card|
      card.include_set_modules
      card.update_column :search_content, card.content_for_search
    end
  end
end
