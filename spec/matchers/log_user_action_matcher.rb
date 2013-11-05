RSpec::Matchers.define :log_user_action do |user, event, subject|
  match do
    log = UserAction.last
    log &&
      log.user == user &&
      log.event.to_s == event.to_s &&
      log.subject == subject
  end
  failure_message_for_should do
    action = UserAction.last
    p action
    "The last logged user action should have been\n"+
      "#{event} #{subject} by #{user}\n" +
      ", but was:\n" +
      "#{action.event} #{action.subject} by #{action.user}"
  end
end

