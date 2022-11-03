include_set Abstract::IdList

def ok_item_types
  :flag_type
end

format :html do
  # LOCALIZE
  before :title do
    voo.title = "Flag Type"
  end

  def input_type
    :radio
  end
end
