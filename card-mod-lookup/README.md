<!--
# @title README - mod: lookup
-->

# Lookup mod

This mod manages lookup tables that help decko sites scale as their decks
grow increasingly large and their queries increasingly complex.

## Why

CQL is a powerful language for navigating card relationships. It is easy, for
example, to find all the cards of a given type that have a field card of a given
name that link to a third card with given content and on and on and on.

But to work, these CQL queries must be translated into SQL and executed, 
and when a database grows large, it can become quite expensive to execute all
the implied self joins.

For example, consider the use case that first inspired this code: _records_ on
wikirate.org. Wikirate is a site that collects records to questions about 
companies. A given record is a response to a given metric for a given year
for a given company. When you consider all the kinds of companies and metrics
and metric designers that Wikirate supports, you can imagine the queries 
becoming quite complex if we have to re-join the cards table to itself every
time we want to consider a different variable.

The solution was to make a "lookup" table for records that employs much more
conventional relational database design. 

_An increasingly common Decko pattern is to design structures organically and
fluidly with cards and then to optimize those structures with lookup tables once
the structures have matured. This pattern can be a surprisingly pleasant change
to those accustomed to having to try to perfect their data structure before
they've collected any data._

## How

### LookupTable

To create a lookup table, you will need to create a database table (most
often by using Rails migrations) and a ruby class like the following `Country`
lookup:

in lib/country.rb:
```
# class for lookup table named "countries"
class Country < Cardio::Record

  # country_id in countries table corresponds to id of company card
  @card_column = :country_id
  
  # query of all cards in lookup
  @card_query = { type_id: :company, trash: false }

  include LookupTable
  
  # The following three are equivalent.
  # Each would populate a `continent_id` column based on a value returned 
  # by the continent_id method on the country card.
  
  # explicit fetch method
  def fetch_continent_id
    card.continent_d
  end
  
  # fetcher with hash argument. hash value becomes method
  fetcher continent_id: :continent_id
  
  # fetcher with symbol arguments. column name and method must be the same
  fetcher :continent_id
  
```

### Abstract::Lookup

in set/type/country.rb:
```
# methods for accessing lookup entries
include_set Abstract::Lookup

# events for maintaining lookup sync
include_set Abstract::LookupEvents

# record class from above
def lookup_class
  ::Country 
end

# called by lookup instance; uses cards
def continent_id
  fetch(:continent)&.id
end

# uses lookup table
def continent_id_from_lookup
  lookup.continent_id
end

```

### Abstract::LookupField

in set/right/continent.rb
```
# methods for maintaing companies table when continent changes
# (admittedly an infrequent occurence)
include_set Abstract::LookupField
```


### Abstract::LookupSearch

Include this set to gain a helpful framework for developing a filter interface
for lookup tables.



