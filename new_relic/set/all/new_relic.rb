event :new_relic_act_transaction, after: :act, when: :new_relic_tracking? do
  action = @action || :create # not sure why @action is sometimes nil on create?
  name_new_relic_transaction [action, type_code], category: :controller
  add_new_relic_card_attributes
end

event :new_relic_read_transaction,
      before: :show_page, on: :read, when: :new_relic_tracking? do
  format = Env[:controller]&.request&.format
  name_new_relic_transaction ["read", type_code, format], category: :controller
  add_new_relic_card_attributes
end

event :notify_new_relic, after: :notable_exception_raised, when: :new_relic_tracking? do
  ::NewRelic::Agent.notice_error Card::Error.current
end

event :new_relic_act_start, before: :act, when: :new_relic_tracking? do
  @act_start = Time.now
end

::Card::Set::Event::IntegrateWithDelayJob.after_perform do |job|
  ActManager.contextualize_delayed_event *job.arguments[0..3] do
    card = job.arguments[1]
    card.name_new_relic_transaction job.queue_name
    card.add_new_relic_card_attributes
    card.add_new_relic_act_attributes time=false
  end
end

def new_relic_tracking?
  Rails.env.production?
end

private

def name_new_relic_transaction name_parts, args={}
  name = name_parts.compact.join "-"
  ::NewRelic::Agent.set_transaction_name name, args
end

def add_new_relic_card_attributes
  ::NewRelic::Agent.add_custom_attributes(
    card: { type: type_code, name: name },
    user: { roles: all_roles.join(", ") }
  )
end

def add_new_relic_act_attributes time=true
  args = { act: { actions: action_names_for_new_relic } }
  args[:time] = "#{(Time.now - @act_start) * 1000} ms" if time
  ::NewRelic::Agent.add_custom_attributes args
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
