class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :yt_client, :confirmation_approver?

  # Ensure authorization happens on every action in the application.
  # This will raise an exception if authorization is not performed in an action.
  # See https://github.com/ryanb/cancan#4-lock-it-down
  check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    logger.warn "Unauthorized access: trying to #{exception.action} #{exception.subject}"
    if exception.action == :create and exception.subject.instance_of? Contribution
      redirect_to exception.subject.project, alert: exception.message
    elsif exception.action == :edit and exception.subject.instance_of? Contribution
      redirect_to exception.subject.project, alert: exception.message
    else
      redirect_to root_url, alert: exception.message
    end
  end

  def yt_client
    @yt_client ||= YouTubeIt::Client.new(username: YT_USERNAME , password: YT_PASSWORD , dev_key: YT_DEV_KEY)
  end
end
