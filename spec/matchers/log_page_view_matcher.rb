RSpec::Matchers.define :log_page_view do |user, controller, action, params|
  match do
    log = PageView.last
    filtered_params = params.inject({}) do |options, (key, value)|
      options[key.to_s] = value.to_s
      options
    end
    log.user == user &&
      log.controller.to_s == controller.to_s
      log.action.to_s == action.to_s &&
      log.parameters.to_s == filtered_params.to_s &&
      log.ip == local_ip
  end

  failure_message_for_should do
    log = PageView.last
    filtered_params = params.inject({}) do |options, (key, value)|
      options[key.to_s] = value.to_s
      options
    end
    "The last logged page view should have been\n"+
      "  #{controller}##{action} by #{user}(#{local_ip}), #{filtered_params}\n" +
      "but was:\n" +
      "  #{log.controller}##{log.action} by #{log.user}(#{log.ip}), #{log.parameters}\n"
  end

  def local_ip
    '0.0.0.0'
  end
end

