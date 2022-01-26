<!--
# @title README - mod: classic
-->

# Classic mod

## What's included?

The classic mod bundles the standard default mods along with other mods that _used to be
standard_ but are no longer included in default installations, specifically:

- [alias](https://github.com/decko-commons/card-mods/tree/main/card-mod-alias), 
which handles aliasing one card name to another
- [google_analytics](
https://github.com/decko-commons/card-mods/tree/main/card-mod-classic
),
which handles google analtyics configuration, and
- [prosemirror_editor](
https://github.com/decko-commons/card-mods/tree/main/card-mod-prosemirror_editor), 
which supports use of the ProseMirror wysiwyg editor.

This bundle is provided predominantly as a transition tool for anyone hoping to minimize
or delay changes to their site, but in the long term it will be considered better 
practice to include those mods individually.

Beyond specifying dependencies (in card-mod-classic.gemspec), this mod adds no
code.

## See also legacy mod

The code included here will be supported moving forward. Additional code from the 
[legacy mod](https://github.com/decko-commons/card-mods/tree/main/card-mod-legacy),
however, will not be well supported moving forward, as its name implies.

## Default HTML view

Tl;dr: if your nests now have titles but didn't used to, you can either:

1. use the legacy mod, or
1. add `config.default_html_view = :content` in `config/application.rb`

Why? Some old decks used the `content` view by default in nests. More recent decks started 
using `titled` instead. It was then possible to override that using `*default html view`
rules. Those rules are being replaced by a new streamlined rule pattern that lets you
set different 