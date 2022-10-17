# Card::ImportCsv loads csv data from a given path or file handle and provides methods
# to iterate over the data.
class Card
  class ImportCsv
    attr_reader :item_class
    delegate :default_header_map, to: :item_class

    # @param headers [true, false, :detect] (false) if true the import raises an error
    #    if the csv file has no or wrong headers
    def initialize(path_or_file, item_class,
                   col_sep: ",", encoding: "utf-8", headers: true)
      @item_class = item_class
      validate_item_class!
      @col_sep = col_sep
      @encoding = encoding

      read_csv path_or_file
      @headers = headers ? map_headers : default_header_map
    end

    # yields the rows of the csv file as simple hashes
    def each_input indices=nil, &block
      if indices
        selected_rows indices, &block
      else
        all_rows &block
      end
    end

    private

    def validate_item_class!
      return if item_class.is_a?(Class) && item_class < ImportItem
      raise ArgumentError, "#{item_class} must inherit from ImportItem"
    end

    def row_count
      @rows.size
    end

    def row_hash index
      row_to_hash @rows[index]
    end

    def selected_rows rows
      rows.each do |index|
        yield row_hash(index), index
      end
    end

    def read_csv path_or_file
      @rows =
        if path_or_file.respond_to?(:read)
          read_csv_from_file_handle path_or_file
        else
          read_csv_from_path path_or_file
        end
    end

    def read_csv_from_path path
      raise StandardError, "file does not exist: #{path}" unless File.exist? path
      rescue_encoding_error do
        CSV.read path, **csv_options
      end
    end

    def read_csv_from_file_handle file
      CSV.parse to_utf_8(file.read, force: true), **csv_options
      # CSV.parse file.read, csv_options
    end

    def rescue_encoding_error
      yield
    rescue ArgumentError => _e
      # if parsing with utf-8 encoding fails, assume it's iso-8859-1 encoding
      # and convert to utf-8
      with_encoding "iso-8859-1:utf-8" do
        yield
      end
    end

    def to_utf_8 str, encoding: "utf-8", force: false
      if force
        str.force_encoding encoding
      else
        str.encode encoding
      end
    rescue Encoding::UndefinedConversionError => _e
      # If parsing with utf-8 encoding fails, assume it's iso-8859-1 encoding
      # and convert to utf-8.
      # If that failed to force it to iso-8859-1 before converting it.
      to_utf_8 str, encoding: "iso-8859-1", force: (encoding == "iso-8859-1")
    end

    def csv_options
      { col_sep: @col_sep, encoding: @encoding }
    end

    def with_encoding encoding
      enc = @encoding
      @encoding = encoding
      yield
    ensure
      @encoding = enc
    end

    def all_rows
      @rows.each.with_index do |row, i|
        next if row.compact.empty?
        yield row_to_hash(row), i
      end
    end

    def row_to_hash row
      @headers.each_with_object({}) do |(column_key, index), h|
        h[column_key] = index ? row[index] : nil
        h[column_key] &&= h[column_key].strip
      end
    end

    def map_headers
      @item_class.map_headers @rows.shift.map(&:to_name)
    end
  end
end
