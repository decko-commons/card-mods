<!--
# @title README - mod: thumbnail
-->

# Thumbnail mod

With this mod installed, any set that includes `Abstract::Thumbnail` will
get a number of helpful (small) image views.

## Views

- __:thumbnail__ - a linked image with a title and subtitle
- __:thumbnail_no_link__ - unlinked image with a title and subtitle
- __:thumbnail_minimal__ - unlinked image with a title (and no subtitle)

### component views
- __:thumbnail_image__ - just the image
- __:thumbnail_subtitle__ - just the subtitle

### configuration
You can also customize the thumbnail view using voo options, eg
```
  nest cardname, view: :thumbnail, size: :large, hide: thumbnail_subtitle
```
voo options include:
- `show`/`hide`: `thumbnail_image`, `thumbnail_link`, `thumbnail_subtitle`
- `size`: `icon`, `small` (default), `medium`, `large`, `original`

## Specifying images

By default, the thumbnail views in this mod apply to `+:image` cards. For 
example, if the `thumbnail` view of a card named `Bunny` would use the
`Bunny+:image` card.

If you need to override this behavior, you can define an `#image_card` method
in the html format that returns the image card that you prefer. For example, 
if you had a `Company` cardtype that stored images as `+:logo`, your company 
set might look something like this:

in type/company.rb:
```
include_set Abstract::Thumbnail

format :html do 
  def image_card
    card.fetch :logo
  end
end
```


