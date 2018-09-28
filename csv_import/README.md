The `csv_import` mod provides a way to import data from csv files.
You can use it to either build a web interface or to write scripts/use the console to import data.

Install the mod in your deck by adding `gem "card-mod-csv_import"` to your deck's Gemfile.

The first step for a csv import is to describe the expected format with a CSVRow class and define what to do with the data in the `import` method.

Let's assume we want to import a csv file with animals that looks like this:
```csv
Animal, Legs, Dangerous
Butterfly, 6, no
Eagle, 2, no
Shark, 0, yes
Monkey, 4, maybe
Platypus, 4, no
```

The CSVRow class for that could look like this:

```ruby
require_dependency "csv_row"

class AnimalCSV < CSVRow
  @columns = [:animal, :legs, :dangerous]
  @required = [:animal]

  # don't accept negative number of legs
  def validate_legs value
    value.to_i >= 0
  end

  # normalize "dangerous" value to boolean
  def normalize_dangerous value
    value != "no"
  end
  
  # what to do with the value of a row in the csv file
  def import
    import_card name: animal, type: :basic,
                subfields: {
                  "legs" => legs,
                  "fondle" => { type: :toggle, content: !dangerous }
                }
  end
end
```

You can use this now to import a csv file in the console with
```ruby
csv_file = CSVFile.new path_to_csv_file, AnimalCSV, col_sep: ",", headers: true
sim = ScriptImportManager.new csv_file, user: "Zookeeper", error_policy: :reports
sim.import
```
In this case all imported cards will be created with the Zookeeper's account. 

If you want users to be able to import csv files on the website then a few more steps are necessary to build the interface.

The general approach is that you create a new cardtype, e.g. "animal import" which inherits from the cardtype "file".
To import a new csv file you create a new "animal import" card, e.g. "south african animals" and attach a csv file to that card.  
When you go to that card you get a link to an "import" view where you can inspect your data, select rows and start the import. You can control the permission of who is able to import with the permissions of the "animal import" cardtype.

To build that you have to

1. create a migration
    ```
    bundle exec decko generate card:migration create_animal_import_cardtype
    ```
   and add to the `up` method in the migration file:
   ```
    ensure_card "animal import", type: :cardtype, codename: "animal_import"
   ```
2. create a set file for that new cardtype `type/animal_import.rb` (the codename has to be the file name)
    ```
    bundle exec decko generate card:set animal_mod type animal_import
    ```
      with content
    ```ruby
    include_set Type::File
    include_set Abstract::Import
    
    attachment :animal_import, uploader: CarrierWave::FileCardUploader
    
    COLUMNS = { animal: "Wild Animals",
                legs: "Number of Legs",
                dangerous: "Dangerous" }.freeze
    
    def csv_row_class
      AnimalCSV
    end
    
    def item_label
      "animal"
    end
    ```
3. run `bundle exec decko update` to execute the migration
