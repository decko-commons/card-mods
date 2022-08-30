
def autoname?
  true
end

format :html do
  def edit_fields
    %i[flag_type status subject discussion]
  end
end
