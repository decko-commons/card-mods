event :new_relic_act_transaction,
      after: :act, when: :production? do
  ::NewRelic::Agent.set_transaction_name "#{@action}-#{type_code}",
                                         category: :controller
  add_custom_card_attributes
  ::NewRelic::Agent.add_custom_attributes(
    act:  {
      time: "#{(Time.now - @act_start) * 1000} ms",
      actions: action_names_for_new_relic
    }
  )
end

event :new_relic_read_transaction,
      before: :show_page, on: :read, when: :production? do
  ::NewRelic::Agent.set_transaction_name "read-#{type_code}",
                                         category: :controller
  add_custom_card_attributes
end

def production?
  Rails.env.production?
end

event :notify_new_relic, after: :notable_exception_raised, when: :production? do
  ::NewRelic::Agent.notice_error Card::Error.current
end

event :new_relic_act_start, before: :act, when: :production? do
  @act_start = Time.now
end

def add_custom_card_attributes
  ::NewRelic::Agent.add_custom_attributes(
    card: {
      type: type_code,
      name: name
    },
    user: {
      roles: all_roles.join(", ")
    },
    params: Env.params
  )
end


::Card::Set::Event::IntegrateWithDelayJob.after_perform do |job|
  ActManager.contextualize_delayed_event *job.arguments[0..3] do
    card = job.arguments[1]
    ::NewRelic::Agent.add_custom_attributes(
      event: job.queue_name,
      card: {
        name: card.name,
        type: card.type_code
      },
      act: { actions: card.action_names_for_new_relic },
    )
  end
end

def action_names_for_new_relic
  return unless (actions = ActManager.act&.actions(false))
  actions.map(&:card).compact.map &:name
end

# test new relic custom metrics
# module ::ActiveRecord::ConnectionAdapters
#   class AbstractMysqlAdapter
#     unless method_defined? :new_relic_execute
#       alias_method :new_relic_execute, :execute
#       def execute sql, name=nil
#         result, duration = count_ms { original_execute(sql, name) }
#         ::NewRelic::Agent.record_metric "Custom/Card/queries", duration
#         result
#       end
#
#       def count_ms
#         start = Time.now
#         result = yield
#         [result, (Time.now - start) * 1000]
#       end
#     end
#   end
# end
