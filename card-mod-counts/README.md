<!--
# @title README - mod: counts
-->

# Counts mod

Counting things can be slow. This mod helps you store and cache counts so you can retrieve
them quickly.

This is a mod for monkeys; it's specifically aimed at optimizing code. The only support
for sharks to date is an override of the `:count` view and a `CQL` extension (see below.)


## Database

Installing the mod will add a `card_counts` table. It mimics the cards table structure by
storing `value` for a unique `left_id` and `right_id`. No card with those two ids is
required; counts are often stored for virtual cards.

## Background jobs

To move counting into the background, you can use `config.card_count = :flag` and
use a cron job or other background mechanism to run `rake card:count:refresh` 
at regular intervals. A typical use is to add a script that calls this rake task to 
`/etc/cron.hourly`. It may often be wise to ensure the call times out before it is
called again.

## Abstract Sets

Each of the following sets works on the same underlying principle: you include it
with `include_set` to make the set ready to handle counts. Note that many sets will
require that you configure recounting.

### Abstract::CachedCount

The base class. The following use it, and it can also be used directly for nonstandard
cases.

### Abstract::ListCachedCount

Count the number of items in an explicit list.

### Abstract::SearchCachedCount

Count the number of items returned by a standard CQL search. `recount_trigger` calls are
required.

### Abstract::ListRefCachedCount

Count a common search pattern: items referred to by a explicit field list. When including
this set, you will need to specify two arguments: `type_to_count` and `list_field`.

## CQL

You can sort by the counts generated with the following CQL
```
sort: { right: RIGHT_NAME, item: "cached_count", return: "count" }
```
