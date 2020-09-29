format :csv do
  view :export do
    raise Card::Error, "type required" unless (type = params[:map_type])

    lines = [["Name in File", "Name in WikiRate", "WikiRate ID"]]
    export_content_lines type, lines
    lines.map { |l| CSV.generate_line l }.join
  end

  def export_content_lines type, lines
    card.map[type.to_sym].map do |key, value|
      lines << [key, value&.cardname, value]
    end
  end
end
