$(document).ready ->
  $('body').on 'click', '._import-status-form ._check-all', (_e) ->
    checked = $(this).is(':checked')
    selectImportRows $(this).closest('._import-status-form'), checked

  $('body').on 'click', '._import-status-refresh', (e) ->
    s = $(this).slot()
    current_tab = s.find(".nav-link.active").data("tab-name")
    s.slotReload(s.slotUrl() + "&tab=" + current_tab)


selectImportRows = (status_form, checked) ->
  status_form.find("._import-row-checkbox").prop 'checked', checked