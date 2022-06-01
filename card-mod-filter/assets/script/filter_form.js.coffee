$(window).ready ->
  $("body").on "submit", "._filter-form", ->
    el = $(this)
    query = el.serializeArray().filter (i) -> i.value
    updateUrlBarWithFilter el, query

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

  $("body").on "click", "._filter-closers a", (e) ->
    link = $(this)
    filters = link.data()
    # "empty" prevents use of default filters but may have other side effects?
    filters.filter = "empty" if $.isEmptyObject filters.filter
    url = decko.path link.closest("form").attr("action") + "?" + $.param(filters)
    link.reloadSlot url
    updateUrlBarWithFilter link, filters
    resetOffCanvas link, filters
    e.preventDefault()

  $("body").on "show.bs.offcanvas", "._offcanvas-filter", ->
    ocbody = $(this).find ".offcanvas-body"
    if ocbody.html() == ""
      path = decko.path ocbody.data("path") + "/filter_bars?" +
        $.param(ocbody.data("query"))
      $.get path, (data) ->
        ocbody.html data
        ocbody.slot().trigger "slot.ready"

resetOffCanvas = (el, query) ->
  ocbody = el.closest("._filtered-content").find ".offcanvas-body"
  ocbody.empty()
  ocbody.data "query", query

updateUrlBarWithFilter = (el, query) ->
  unless el.closest('._noFilterUrlUpdates')[0]
    window.history.pushState "filter", "filter", '?' + $.param(query)

