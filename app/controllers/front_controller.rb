class FrontController < ApplicationController

  hobo_controller

  def index; end

  def impressum; end

  def development; end

  def summary
    if !(current_user.administrator? or current_user.supervisor?)
      redirect_to user_login_path
    end
  end
end
