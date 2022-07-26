
$(document).ready ->
  # bulk selection of import mapping rows via checkbox dropdown
  $('body').on 'click', "._import-map-status-option", (e) ->
    statter = $(this)
    status = statter.data "status"
    importTable(statter).find("#_import-map-item-checkbox:visible").each ->
      updateCheckboxStatus $(this), status
    e.preventDefault()

  $('body').on 'click', "._import-map-action-option", (e) ->
    action = $(this).data "action"
    table = importTable $(this)
    switch
      when action == "show" then showAll table
      when action == "showonly" then eachItem table, ":not(:checked)", hideItem
      else eachItem table, ":checked", actionMap[action]
    e.preventDefault()

  $("body").on "click", "._create-import-item", ->
    btn = $(this)
    if btn.hasClass "active"
      createItem btn
    else
      resetItem btn


  # reset status tab so that it updates when navigating there.
  $('body').on 'click', '._save-mapping', () ->
    $(".tab-pane-import_status_tab").html ""

    tab = $(".TYPE-answer_import.page-view > .tabbable > .nav > .nav-item:nth-child(2) > .nav-link")
    tab.addClass("load")

  # handle metric name selection (new text, new hidden value, new value editor)
  $("body").on "decko.filter.selection", "._suggest-link", (event, item) ->
    data = $(item.firstChild).data() # assumes first child has card data
    newMapping $(this), data.cardName

eachItem = (table, selector, func) ->
  table.find("#_import-map-item-checkbox#{selector}").each ->
    func $(this).closest("._import-map-item")

showAll = (table) ->
  table.find("._import-map-item").show()

# TODO: refactor below; make object oriented!!

importMapping = (el) ->
  importMapItem(el).find "._import-mapping"

mappingLabel = (el) ->
  importMapItem(el).find "._mapping-label"

savedMapping = (el) ->
  importMapItem(el).find "._saved-mapping"

importTable = (el)->
  el.closest(".tab-pane").find "._import-table"



hideItem = (item) ->
  item.find("#_import-map-item-checkbox").prop "checked", false
  item.hide()

importMapItem = (el, selector) ->
  el.closest "._import-map-item#{selector || ''}"

hasStatus = (el, status) ->
  importMapItem(el, "[data-status='#{status}']").length > 0

updateCheckboxStatus = (itemCheckbox, status) ->
  checked = switch
    when status == "all" then true
    when status == "none" then false
    else hasStatus itemCheckbox, status

  itemCheckbox.prop "checked", checked

nameInFile = (el) ->
  importMapItem(el).find("._item-name-in-import-file").text()

updateStatus = (el, status) ->
  item = importMapItem el
  item.attr "data-status", status
  item.find("._import-map-status-label").text statusMap[status]

updateLabel = (el, preface, text) ->
  label = mappingLabel el
  label.html "<strong>#{preface}</strong>: #{text}"
  label.show()

newMapping = (el, cardname) ->
  importMapping(el).val cardname
  savedMapping(el).hide()
  updateLabel el, "New", cardname
  updateStatus el, "matched"

createItem = (el) ->
  importMapping(el).val "AutoAdd"
  savedMapping(el).hide()
  updateLabel el, "Create", nameInFile(el)
  updateStatus el, "matched"

resetItem = (el) ->
  item = importMapItem el
  savedMapping(el).show()
  mappingLabel(el).hide()
  updateStatus el, item.data("savedstatus")
  importMapping(el).val item.data("savedmapping")

actionMap =
  hide: hideItem
  create: createItem
  reset: resetItem

statusMap =
  matched: "Match"
  suggested: "Pending"
  unmatched: "No Match"
