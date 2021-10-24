<!--
# @title README - mod: mirror
-->

# Mirror mod (experimental)

This mod supports maintaining two lists – a _Mirror_ list and a _Mirrored_ list
– that, well, mirror each other. This has sometimes been referred to in Decko
circles as _bidirectionality_

By well-established convention, many card Sharks set up patterns where an
explicit list (a card whose type is List or Pointer) is used by Searches.

For example, imagine you have two cardtypes: `Beans` and `Colors`. You'd like to
be able to go to a Bean card and see all the Colors for that Bean, OR go to a
Color and see all the Beans for that Color. If you use the List/Search pattern,
then one of these is a List and the other is a Search. Say you decide to make it
so the Bean has a List of colors. Then you will need to make it so that the
Color cards have a Search for all the bean lists that refer to that color.

The problem is that only Lists are directly editable. (If you edit a search,
then you're editing a query, not directly adding to or subtracting from the
list).

This mod solves that problem by providing two list types that mirror each other.
Edit one and those changes take effect on the other one.

