<!--
# @title README - mod: CSV imports
-->

# imports mod

The `csv_import` mod provides a way to import data from csv files.
You can use it to either build a web interface or to write scripts/use the console to
import data.

Install the mod in your deck by adding `gem "card-mod-csv_import"` to your deck's Gemfile.

The first step for a csv import is to describe the expected format with an ImportItem
class and translate that into card attributes in the `import_hash` method.

Let's assume we want to import a csv file with animals that looks like this:

```csv
Animal, Legs, Dangerous
Butterfly, 6, no
Eagle, 2, no
Shark, 0, yes
Monkey, 4, maybe
Platypus, 4, no
```

The ImportItem class for that could look like this:

```ruby


class Card
   class AnimalImportItem < ImportItem
     @columns = %i[animal legs dangerous]
   
     # don't accept negative number of legs
     def validate_legs value
       value.to_i >= 0
     end
   
     # normalize "dangerous" value to boolean
     def normalize_dangerous value
       value != "no"
     end
   
     # what to do with the value of a row in the csv file
     # the #input method will return a Hash in which the keys are the column names
     # and the values are the normalized values
     def import_hash
        i = input.clone
        { name: i[:animal],
          fields: {
            legs: i[:legs],
            petting: { type: :toggle, content: !i[:dangerous] }
          }
        }
     end
  end
end
```

You can use this now to import a csv file in the console with

```ruby
csv_file = CSVFile.new path_to_csv_file, AnimalImportItem, col_sep: ",", headers: true
sim = ScriptImportManager.new csv_file, user: "Zookeeper", error_policy: :reports
sim.import
```

In this case all imported cards will be created with the Zookeeper's account.

Note that the columns can be listed in any order, but the headers must match known
headers. Unrecognized headers will be ignored.

## Column configuration

The example above illustrates the simple Array-style column configuration, but it is
also possible to do more advanced configuration with a Hash representation.

```ruby
  @columns = { 
               column1: { setting1: value1, setting2: value2 },
               column2: {}
             }
```

The following configuration options are available:

- **optional** - column values are not required
- **separator** for cells containing multiple values, use this separator to delineate them
- **map** - attempt to map the column to an existing cardname
- **suggest** - when mapping and no exact match is found, offer suggestions
- **auto add** for mapped columns, offer to add cards when no match is found

## Import and Mapping UI
If you want users to be able to import csv files on the website then a few more steps are
necessary to build the interface.

The general approach is that you create a new cardtype, e.g. "animal import" that 
includes the `Abstract::Import` set.

_in set/type/animal_import:_

```ruby
  include_set Abstract::Import

   def import_item_class
      AnimalImportItem
   end
```

To import a new csv file you create a new "animal import" card, e.g. "south african
animals" and attach a csv file to that card. When you go to that card you will see an
"import" view where you can inspect your data, select rows and start the import.

You can control the permission of who is able to import with the permissions of the 
"animal import" cardtype.

