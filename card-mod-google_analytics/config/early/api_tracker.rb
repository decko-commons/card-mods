ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  Card::ApiTracker.track event
end
