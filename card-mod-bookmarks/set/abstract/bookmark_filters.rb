format :html do
  def filter_bookmark_type
    :radio
  end

  def filter_bookmark_options
    { "I bookmarked" => :bookmark,
      "I did NOT bookmark" => :nobookmark }
  end
end
