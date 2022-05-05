basket[:list_input_options] << :filtered_list

def supports_content_option_view?
  super || (item_name == "filtered list")
end

format :html do
  wrapper :filtered_list_item, template: :haml do
    haml :filtered_list_item
  end
end
