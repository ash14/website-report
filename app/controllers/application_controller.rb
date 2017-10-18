class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :resource_name, :resource

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def after_sign_in_path_for(resource)
    report_path
  end
end
