# TODO: make filter form an object

decko.filter =
  refilter: (el) ->
    form = decko.filter.resultsForm el
    query = form.data "query"
    query["refilter"] = true
    url = decko.path form.attr("action") + "?" + $.param(query)
    form.slot().slotReload url
    updateUrlBarWithFilter form, query
    resetOffCanvas form

  updateUrl: (el) ->
    form = decko.filter.resultsForm el
    query = form.data "query"
    updateUrlBarWithFilter form, query

  query: (el) ->
    decko.filter.resultsForm(el).data "query"

  resultsForm: (el)->
    decko.filter.findInFilteredContent el, "form.filtered-results-form"

  findInFilteredContent: (el, selector) ->
    $(el).closest("._filtered-content").find selector

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
    removeFromQuery $(this)
    decko.filter.refilter this
    e.preventDefault()

  $("body").on "change", "._filtered-results-header ._filter-sort", (e) ->
    sel = $(this)
    decko.filter.query(sel).sort_by = sel.val()
    decko.filter.refilter this
    e.preventDefault

  $("body").on "show.bs.offcanvas", "._offcanvas-filter", ->
    ocbody = $(this).find ".offcanvas-body"
    return unless ocbody.html() == ""

    query = decko.filter.query ocbody
    path = decko.path ocbody.data("path") + "/filter_bars?" + $.param(query)
    $.get path, (data) ->
      ocbody.html data
      ocbody.slot().trigger "decko.slot.ready"

  $("body").on "click", "._filtered-body-toggle", (e) ->
    link = $(this)
    link.parent().children().removeClass "btn-light"
    link.addClass "btn-light"
    decko.filter.query(link).filtered_body = link.data("view")
    decko.filter.refilter this
    e.preventDefault()

  $("body").on "click", "._filtered-results-header ._quick-filter-link", (e) ->
    link = $(this)
    if link.data "filter"
      addToQuery $(this)
    else
      removeFromQuery $(this)
    decko.filter.refilter this
    e.preventDefault()

resetOffCanvas = (el) ->
  ocbody = decko.filter.findInFilteredContent el, ".offcanvas-body"
  ocbody.parent().offcanvas "hide"
  ocbody.empty()

updateUrlBarWithFilter = (el, query) ->
  unless el.closest('._noFilterUrlUpdates')[0]
    query_string = '?' + $.param(query)
    items = el.slot().data("slot")["items"]
    if (tab = el.closest(".tabbable").find(".nav-link.active").data("tabName"))
      query_string += "&tab=" + tab
    if items?
      query_string += "&" +  $.param({ filter_items: items })
    window.history.pushState "filter", "filter", query_string

removeFromQuery = (link) ->
  query = decko.filter.query link
  remove = link.data "removeFilter"
  if remove == "all"
    query["filter"] = "empty"
  else
    removeSingleFilter query.filter, remove[0], remove[1]

addToQuery = (link) ->
  query = decko.filter.query link
  add = link.data "filter"
  addSingleFilter query.filter, add[0], add[1]

removeSingleFilter = (filter, key, value) ->
  value = value[0] if Array.isArray value
  if Array.isArray filter[key]
    i = filter[key].indexOf value
    filter[key].splice i, 1
  else
    delete filter[key]

addSingleFilter = (filter, key, value) ->
  console.log "addSingleFilter: #{filter}, #{key}, #{value}"
  if Array.isArray filter[key]
    filter[key].push value[0]
  else
    filter[key] = value


#  $("body").on "click", "a.card-paging-link", ->
#    id = $(this).slot().attr("id")
#  consider using pushState with paging, too.
