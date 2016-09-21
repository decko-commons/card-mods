event :new_relic_act_transaction,
      before: :act do
  ::NewRelic::Agent.set_transaction_name "#{@action}-#{type_code}",
                                         category: :controller
  add_custom_card_attributes
end

event :new_relic_add_actions, after: :act do
  ::NewRelic::Agent.set_transaction_name "#{@action}-#{type_code}",
                                         category: :controller
  add_custom_card_attributes
end

event :new_relic_read_transaction,
      before: :show_page, on: :read do
  ::NewRelic::Agent.set_transaction_name "read-#{type_code}",
                                         category: :controller
  add_custom_card_attributes
end

event :notify_new_relic, after: :notable_exception_raised do
  ::NewRelic::Agent.notice_error Card::Error.current
end

def add_custom_card_attributes
  ::NewRelic::Agent.add_custom_attributes(
    card: {
      type: type_code,
      name: name
    },
    user: {
      roles: all_roles.join(", ")
    }
  )
end
