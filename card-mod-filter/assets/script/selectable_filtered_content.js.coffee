$(window).ready ->
  $('body').on "ajax:beforeSend", "._selectable-filter-link", (_event, _xhr, opt)->
    opt.noSlotParams = true

  $("body").on "ajax:success", "._selectable-filter-link", ->
    $("._selectable-filtered-content").data "source-link", $(this)

  $("body").on "click", "._selectable-filtered-content .search-result-item", (e) ->
    item = $(this)
    source_link = item.closest("._selectable-filtered-content").data "source-link"
    source_link.trigger "filter:selection", item
    item.closest(".modal").modal "hide"
    e.preventDefault()
    e.stopPropagation()
