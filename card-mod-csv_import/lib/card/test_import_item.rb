class Card
  # ImportItem instance used only for testing
  class TestImportItem < ImportItem
    @columns = { nickname: {},
                 basic: { map: true, auto_add: true },
                 cash: {} }

    def self.basic_suggestion_filter name, _import_manager
      { basically: name }
    end

    # what to do with the value of a row in the csv file
    # the #input method will return a Hash in which the keys are the column names
    # and the values are the normalized values
    def import_hash
      i = input.clone
      { name: i[:nickname],
        fields: {
          home: i[:basic],
          credit: { type: :toggle, content: !i[:cash] }
        } }
    end
  end
end
