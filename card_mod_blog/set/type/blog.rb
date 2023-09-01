card_accessor :image
card_accessor :description
card_accessor :date, type: :date

format :html do
  def edit_fields
    %i[date image description]
  end
  
  view :core, template: :haml
end
