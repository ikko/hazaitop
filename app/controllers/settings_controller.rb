# -*- encoding : utf-8 -*-
class SettingsController < ApplicationController

  hobo_model_controller

  auto_actions :index

  def index
    if current_user.administrator?
      hobo_index
    else
      redirect_to '/'
    end
  end
end

