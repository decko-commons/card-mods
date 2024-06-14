# TODO: make filter form an object

decko.filter =
  refilter: (form, query) ->
    query ||= form.data("query")
    url = decko.path form.attr("action") + "?" + $.param(query)
    form.slot().slotReload url
    updateUrlBarWithFilter form, query
    resetOffCanvas form

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
    decko.filter.refilter link.closest("form"), link.data()
    e.preventDefault()

  $("body").on "change", "._filtered-results-header ._filter-sort", (e) ->
    sel = $(this)
    query(sel).sort_by = sel.val()
    decko.filter.refilter sel.closest("form")
    e.preventDefault

  $("body").on "show.bs.offcanvas", "._offcanvas-filter", ->
    ocbody = $(this).find ".offcanvas-body"
    return unless ocbody.html() == ""

    path = decko.path ocbody.data("path") + "/filter_bars?" + $.param(query(ocbody))
    $.get path, (data) ->
      ocbody.html data
      ocbody.slot().trigger "decko.slot.ready"

  $("body").on "click", "._filtered-body-toggle", (e) ->
    link = $(this)
    link.parent().children().removeClass "btn-light"
    link.addClass "btn-light"
    query(link).filtered_body = link.data("view")
    decko.filter.refilter link.closest("form")
    e.preventDefault()

query = (el) ->
  form = $(el).closest(".filtered_content-view").find "form.filtered-results-form"
  form.data "query"

resetOffCanvas = (el) ->
  ocbody = el.closest("._filtered-content").find ".offcanvas-body"
  ocbody.parent().offcanvas "hide"
  ocbody.empty()

updateUrlBarWithFilter = (el, query) ->
  unless el.closest('._noFilterUrlUpdates')[0]
    query_string = '?' + $.param(query)
    if (tab = el.closest(".tabbable").find(".nav-link.active").data("tabName"))
      query_string += "&tab=" + tab
    window.history.pushState "filter", "filter", query_string


#  $("body").on "click", "a.card-paging-link", ->
#    id = $(this).slot().attr("id")
# consider using pushState with paging, too.
