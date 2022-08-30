assign_type :pointer

format :html do
  before :title do
    voo.title ||= "Flag Type"
  end

  def input_type
    :radio
  end
end