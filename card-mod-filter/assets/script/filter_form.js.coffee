decko.filter =
  refilter: (form, data) ->
    data.filter = "empty" if $.isEmptyObject data.filter
    url = decko.path form.attr("action") + "?" + $.param(data)
    form.slot().slotReload url
    updateUrlBarWithFilter form, data
    resetOffCanvas form, data


$(window).ready ->
  $("body").on "submit", "._filter-form", ->
    debugger

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
    decko.filter.refilter link.closest("form"), link.data()
    e.preventDefault()

  $("body").on "change", "._filtered-results-header ._filter-sort", (e) ->
    sel = $(this)
    form = sel.closest "form"
    data = form.data()
    data.sort_by = sel.val()
    decko.filter.refilter form, data
    e.preventDefault()

  $("body").on "show.bs.offcanvas", "._offcanvas-filter", ->
    ocbody = $(this).find ".offcanvas-body"
    if ocbody.html() == ""
      path = decko.path ocbody.data("path") + "/filter_bars?" +
        $.param(ocbody.data("query"))
      $.get path, (data) ->
        ocbody.html data
        ocbody.slot().trigger "decko.slot.ready"

resetOffCanvas = (el, query) ->
  ocbody = el.closest("._filtered-content").find ".offcanvas-body"
  ocbody.empty()
  ocbody.data "query", query

updateUrlBarWithFilter = (el, query) ->
  unless el.closest('._noFilterUrlUpdates')[0]
    window.history.pushState "filter", "filter", '?' + $.param(query)

