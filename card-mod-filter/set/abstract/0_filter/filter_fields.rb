format :html do
  def filter_config category
    @filter_config ||= {}
    @filter_config[category] ||=
      %i[type default options label].each_with_object({}) do |trait, hash|
        method = "filter_#{category}_#{trait}"
        hash[trait] = send method if respond_to? method
      end
  end

  def filter_name_type
    :text
  end

  def filter_label field
    filter_config(field)[:label] || filter_label_from_name(field)
  end

  def filter_label_from_name field
    Card.fetch_name(field) { field.to_s.sub(/^\*/, "").titleize }
  end

  def filter_closer_value field, value
    try("filter_#{field}_closer_value", value) || value
  end

  def filter_options raw
    return raw if raw.is_a? Array

    raw.each_with_object([]) do |(key, value), array|
      array << [key, value.to_s]
      array
    end
  end

  def type_options type_codename, order="asc", max_length=nil
    Card.cache.fetch "#{type_codename}-TYPE-OPTIONS" do
      res = Card.search type: type_codename, return: :name, sort_by: "name", dir: order
      max_length ? (res.map { |i| [trim_option(i, max_length), i] }) : res
    end
  end

  def trim_option option, max_length
    option.size > max_length ? "#{option[0..max_length]}..." : option
  end
end
