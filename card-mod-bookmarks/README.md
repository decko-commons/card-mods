<!--
# @title README - mod: bookmarks
-->

# Bookmarks mod

This mod provides functionality for:

- bookmarking / unbookmarking cards with a single click
- db storage of those bookmarks for signed-in users
- session storage for non-signed in users
- saving session bookmarks in db when users create accounts
- navigating one's bookmarked content
- letting users "follow" cards they have bookmarked

## Sets modified

### Abstract::Bookmarkable

By including this set (via `include_set Abstract::Bookmarkable`), a set is made
bookmarkable. It has a `:toggle_bookmark` event that can be triggered using the
standard trigger API. Eg `card.update! trigger: :toggle_bookmark`.

It also provides a `#currently_bookmarked?` method, as well as the following
views:

- :bookmark - shows the toggleable bookmark icon and the number of bookmarkers
- :title_with_bookmark - prepends the bookmark view to a title.
- :box_top - uses :title_with_bookmark in boxes
- :bar_left - uses :title_with_bookmark in bars

### Abstract::Bookmarker

A bookmarker is a user that bookmarks. Any set that includes this one will be
able to bookmark other sets.

### Abstract::Accountable

Extended to include `Abstract::Bookmarker`. Because most user sets already
include `Abstract::Accountable`, monkeys will seldom need to
include `Abstract::Bookmarker` explicitly.

### Right::Account (Cards that end in +*account)

Extended with `:save_session_bookmarks` event so that session bookmarks can be
saved when an account is created.

### Right::Bookmarkers (Cards that end in +bookmarkers)

Searches that handle counting number of bookmarkers that have bookmarked a given
card.

### Right::Bookmarks (Cards that end in +bookmarks)

These are the cards that actually store the bookmarks. For example, if `Joe
User` bookmarks the card named `Pineapple`, then `Joe User+bookmarks` will 
be a list of cards that contains the item `Pineapple`

### Self::Anonymous (the card "Anonymous")

When a user is not signed in, the "Anonymous" card acts as their user card.
This mod extends that card to allow for anonymous bookmarks to be stored in
the session.

### Self::Bookmarked (the card "Bookmarked")

This card is created as a follow option, making it possible to follow cards
that you have bookmarked.
