<!--
# @title README - mod: social
-->

# Social mod

This mod adds Twitter and OpenGraph meta tags to decko cards.

## Tags shared by both

Both OpenGraph and Twitter support `description` and `image` fields.

- The __description__ is handled by the `#social_description` method, which can be
  overwritten in any set. By default it renders the `:text_without_nests` view (in the
  Text format) of the `+:description` card (which itself can be overwrtten using
  the `#social_description_card` method.
- The __image__ is handled by the `#social_image` method, which can be overwritten in any
  set. By default it renders the `:source` view of the `+:image` card (which itself can be
  overwrtten using the `#social_image_card` method.

If you want different content for the two, you can override `#og_description`, 
`#og_image`, `#twitter_description`, and/or `#twitter_image`.

## Open Graph tags

The following additional OpenGraph meta tags are also generated (and overridable):

- __#og_url__: by default the card's url with no extension
- __#og_site_name__: by default the content of the `:title` card
- __#og_type__: defaults to "article"
- __#og_title__: defaults to the card name

## Twitter tags

This mod also adds an overridable __#twitter_card__ meta tag that defaults to "summary".
