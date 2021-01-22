event :new_relic_act_transaction, after: :act, when: :new_relic_tracking? do
  add_new_relic_card_attributes
  add_new_relic_act_attributes unless @action == :read
  name_new_relic_transaction new_relic_transaction_name_parts, category: :controller
end

event :notify_new_relic, after: :notable_exception_raised, when: :new_relic_tracking? do
  ::NewRelic::Agent.notice_error Card::Error.current
end

event :new_relic_act_start, before: :act, when: :new_relic_tracking? do
  @act_start = Time.now
end

::Card::Set::Event::IntegrateWithDelayJob.after_perform do |job|
  Director.contextualize_delayed_event *job.arguments[0..3] do
    card = job.arguments[1]
    card&.track_delayed_job job
  end
end

# for override. cards with same label are grouped in new relic reporting
def new_relic_label
  type_code
end

def new_relic_tracking?
  Rails.env.production?
end

def track_delayed_job job
  name_new_relic_transaction ["delayed-#{job.queue_name}"]
  add_new_relic_card_attributes
  add_new_relic_act_attributes time=false
end

private

def new_relic_transaction_name_parts
  controller = Env[:controller]
  parts = [controller&.action_name, new_relic_label]
  return parts unless @action == :read

  parts << controller&.response_format
end

def name_new_relic_transaction name_parts, args={}
  name = Array.wrap(name_parts).compact.map(&:to_s).join "-"
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
  args[:time_from_start] = "#{(Time.now - @act_start) * 1000} ms" if time
  ::NewRelic::Agent.add_custom_attributes args
end

def action_names_for_new_relic
  return unless (actions = Director.act&.actions(false))
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
