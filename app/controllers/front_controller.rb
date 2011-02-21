class FrontController < ApplicationController

  hobo_controller

  caches_page :index, :expires_in => 4.minutes
  caches_page [:impressum, :development] :expires_in => 90.minutes

  def index; end

  def impressum; end

  def development; end

  def summary
    if !(current_user.administrator? or current_user.supervisor?)
      redirect_to user_login_path
    end
  end
end
