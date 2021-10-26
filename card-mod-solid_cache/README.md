<!--
# @title README - mod: solid cache
-->

# Solid Cache mod (experimental)

This mod supports caching rendered card content in the database.

## Why

Decko has a powerful caching system that handles caching code objects
(especially cards) and rendered views. The view caching is smart about nests and
generally caches nested content separately from the content that nests it, so
that you don't have to expire the cache of the nesting content so frequently. In
most cases, this is a fast and efficient way to handle content.

However, there are cases where a deeper and more permanent cache is appropriate.
Sometimes it's more important that a very complex page be fast than perfectly up
to date, for example. This mod can be helpful in such cases.

## How

If you include `Abstract::SolidCache` in a set, then anything that renders the
`:core` view of a card in that set will trigger the generation of a
`+:solid_cache` card. That raw content (db_content) of that new cache card will
contain the rendered core view of the original card. Any further rendering of
the core view will use that cached view until the cache is explicitly cleared or
updated.

To clear or update the cache, you will need to call one of the following methods
to the set of a card that should clear/update the cache when changed.

- `#cache_update_trigger`
- `#cache_expire_trigger`

See {Card::Set::Abstract::SolidCache} for more on those methods.