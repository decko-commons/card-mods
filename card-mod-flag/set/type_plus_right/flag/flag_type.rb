include_set Abstract::IdPointer

format :html do
  # LOCALIZE
  before :title do
    voo.title = "Flag Type"
  end

  def input_type
    :radio
  end
end
