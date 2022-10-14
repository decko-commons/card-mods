class ::Card
  class TestImportItem < ImportItem
    @columns = { nickname: {},
                 house: { map: true },
                 cash: {} }

    def validate_house _value
      true
    end

    # what to do with the value of a row in the csv file
    # the #input method will return a Hash in which the keys are the column names
    # and the values are the normalized values
    def import_hash
      i = input.clone
      { name: i[:nickname],
        fields: {
          home: i[:house],
          credit: { type: :toggle, content: !i[:cash] }
        }
      }
    end
  end
end
