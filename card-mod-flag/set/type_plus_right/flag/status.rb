include_set Abstract::FlagField

# LOCALIZE
def option_names
  %w[open closed]
end

def default_content
  "open"
end

format :html do
  before :title do
    voo.title = "Status"
  end

  def input_type
    :radio
  end
end
