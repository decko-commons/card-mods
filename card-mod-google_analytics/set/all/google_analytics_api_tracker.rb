
def api_tracker_event_params
  {
    cardtype: type_name,
    cardtype_id: type_id,
    card_id: id || "",
    card_name: name,
    error_message: api_tracker_error_message
  }
end

def api_tracker_error_message
  format(:text).error_messages.join "; "
end

# def api_tracker_status_code
#   Env.controller.format.error_status || 200
# end
format do
  def api_tracker_event_params
    { result_count: api_tracker_result_count }
  end

  def api_tracker_result_count
    @search_with_params.present? ? @search_with_params.count : ""
  end
end
