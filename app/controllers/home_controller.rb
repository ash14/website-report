class HomeController < ApplicationController
  protect_from_forgery with: :exception

  def index
    if user_signed_in?
      redirect_to report_path
    else
      redirect_to new_user_session_path
    end
  end
end
