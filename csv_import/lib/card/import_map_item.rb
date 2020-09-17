class Card
  # methods for each item in a +import map card
  class ImportMapItem
    attr_reader :map_card, :type, :cardname, :name_in_file

    def initialize map_card, type, name_in_file, cardname
      @map_card = map_card
      @type = type
      @name_in_file = name_in_file
      @cardname = cardname
    end

    def normalize
      normalize_cardname do
        handling_auto_add do
          mapped_id || invalid_mapping
        end
      end
    rescue StandardError => e
      invalid_mapping e.message
    end

    def auto_add?
      cardname == "AutoAdd" && map_card.auto_add_type?(type)
    end

    def auto_add
      map_card.import_item_class.auto_add type, name_in_file if auto_add?
    rescue StandardError => _e
      "AutoAddFailure"
    end

    private

    # FIXME: could break if type and column have different names
    def mapped_id
      map_card.import_item_class.new(type => cardname).map_field type, cardname
    end

    def invalid_mapping error=nil
      message = "invalid #{type} mapping: #{cardname}"
      message += " (#{error})" if error
      map_card.errors.add :content, message
      nil
    end

    def handling_auto_add
      auto_add? || cardname == "AutoAddFailure" ? cardname : yield
    end

    def normalize_cardname
      @cardname = Card::Env::Location.cardname_from_url(cardname) || cardname
      cardname.blank? ? nil : yield
    end
  end
end
