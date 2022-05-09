$(window).ready ->
  $("body").on "submit", "._filter-form", ->
    # TODO: make this opt-in rather than opt out
    unless $(this).closest('._noFilterUrlUpdates')[0]
      query = $(this).serializeArray().filter (i)->
        i.value
      window.history.pushState "filter", "filter", '?' + $.param(query)

  $("body").on "click", "._show-more-filter-options a", (e) ->
    a = $(this)
    items = a.closest("._filter-list").find "._more-filter-option"
    if a.text() == "show more"
      items.show()
      a.text "show less"
    else
      items.hide()
      a.text "show more"
    e.preventDefault()
