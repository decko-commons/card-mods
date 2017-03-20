$(window).ready ->
  $('body').on 'click', '.typeset-button', (event) ->
    $form = $(this).closest('form')
    $submit_button = $form.find("button.submit-button")

    $submit_button.removeAttr("data-disable-with")
    $(this).attr("data-disable-with","Typesetting")
    $(this).attr("type","submit")
    $form.find('#success_redirect').val('false')
    $form.find('#success_typeset').val('true')
    $form.find('#success_view').val('edit_preview')
    $form.attr('data-slot-success-selector', '#splitviewpdf > div')

    $form.submit()

    $form.removeAttr('data-slot-success-selector')
    # $(this).removeAttr("data-disable-with")
    $(this).removeAttr("type","submit")
    # $submit_button.attr("data-disable-with", "Submitting")
    $form.find('#success_redirect').val('true')
    $form.find('#success_typeset').val('false')
    $form.find('#success_view').val('open')

  $('body').on 'click', '.submit-button', (event) ->
    $form = $(this).closest('form')
    buttons = $form.find(':submit').not($(this))
    buttons.removeAttr('data-disable-with')
    $(this).attr("data-disable-with","Submitting")
    buttons.attr('disabled', true)
