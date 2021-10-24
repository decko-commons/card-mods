<!--
# @title README - mod: export
-->

# Export mod

Supports adding export links to search cards.

NOTE: this mod does not provide any additional search mechanisms or views in export
formats; it's just for the links.

Employ by using `include_set Abstract::Export`. This will provide an `:export_links` view,
which will include export links for each format returned by `#export_formats` (which
defaults to `:csv` and `:json`).
