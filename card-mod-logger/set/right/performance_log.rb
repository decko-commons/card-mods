def log_dir
  dir = File.join File.dirname(Decko.paths['log'].existent.first), 'performance'
  Dir.mkdir dir unless Dir.exists? dir
  dir
end

def log_path item
  File.join log_dir, "#{item.gsub('&#47;','_').gsub(/[^0-9A-Za-z.\-]/, '_')}.log"
end

def csv_path
  File.join log_dir, "#{cardname.safe_key}.csv"
end

def add_log_entry request, html_log
  time = Time.now.utc.strftime "%Y%m%d%H%M%S"
  item_name = "%s+%s %s" % [name, time, request.gsub('/','&#47;') ]
  if include_item? item_name
    item_name += 'a'
    while include_item? item_name
     item_name.next!
    end
  end

  Card::Auth.as_bot do
    File.open(log_path(item_name), 'w') {|f| f.puts html_log}
    add_item! item_name
  end
end

def add_csv_entry page, wbench_data, runs
  unless File.exist? csv_path
    File.open(csv_path, 'w') { |f| f.puts "page, render time, dom loading time, connection time, date"}
  end
  browser = wbench_data.browser
  runs.times do |i|
    csv_data = [
      page,
      browser['responseEnd'][i] - browser['requestStart'][i],
      browser['domComplete'][i] - browser['domLoading'][i], # domLoadingTime
      browser['requestStart'][i],  # domLoadingStart
      Time.now.utc.inspect
    ]
    csv_line = CSV.generate_line(csv_data)
    File.open(csv_path, 'a') { |f| f.puts csv_line }
  end

  if left != Card[:all]
    all = Card.fetch "#{Card[:all].name}+#{Card[:performance_log].name}", :new=>{}
    all.add_csv_entry page, wbench_data, runs
  end
end

format :html do
  view :core do
    wagn_data =
      card.item_names.map do |item|
        path = card.log_path item
        if File.exist? path
          File.read(path)
        end
      end.compact.join "\n"
    browser_data = CSV.parse(File.read(card.csv_path))
    output [
      table(browser_data, header: true),
      wagn_data
    ]
  end
end

