format :html do
  def filter_bookmark_type
    :select
  end

  def filter_bookmark_options
    { "I bookmarked" => :bookmark,
      "I did NOT bookmark" => :nobookmark }
  end
end
