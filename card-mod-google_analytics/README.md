<!--
# @title README - mod: google analytics
-->

# Google Analytics mod

This mod supports the inclusion of Google Analytics snippets in the `<head>` tag
of Decko pages.

_Note: this mod currently supports only Universal Analytics, but GA4 support is
coming soon._

## Client-side tracking: Snippets

To add a snippet, Monkeys can add a universal analytics key for your GA property
to `config.google_analytics_key`. Sharks can also edit
the `:google_analytics_key` card.

## Server-side tracking (experimental)

It is possible to send information to Google Analytics about server requests
that never go through a browser (and therefore can't be captured using 
snippets). Any request for which the method `#track_page_from_server?` 
returns true for the main card will send information to the Google Analytics
account configured. If you want these requests to go to a different property
(which is recommended, because without the extra browser information, these
requests have far less metadata and are thus harder for GA to interpret as 
part of continuous user journeys), then you can add a key for that property
using `config.google_analytics_tracker_key`.
