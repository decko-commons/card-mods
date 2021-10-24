<!--
# @title README - mod: fulltext
-->

# Fulltext mod

This mod adds MySQL fulltext support for card searches.

It does so by adding a `search_content` field to the cards table and indexing the
`name` and `search_content` fields.

For simple cards, the `search_content` simply duplicates the `db_content` field (which
contains default card content). But the fulltext search becomes much more powerful if
the `search_content` is customized for different sets, often by including the content of
select related cards.

## CQL

This mod adds support for fulltext matching in card queries, eg:

    fulltext_match: "MYKEYWORD"

Alternatively, you can trigger a fulltext match using a `:` prefix with a standard
match statement.

    match: ":MYKEYWORD"

It also adds support for relevance sorting:

    sort: "relevance"

## Sets

### Abstract::SearchContentFields

After including this set, you can add a `#search_content_field_codes` method that returns
a list of codenames. The `#search_content` field will be populated by concatenating
the content of those fields.

### Abstract::NoSearchContent

With this set, the `search_content` will be blank (and fulltext matching will be use
only the name field)

