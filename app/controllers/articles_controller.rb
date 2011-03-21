class ArticlesController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def new
    fill_drop_down
    hobo_new
  end

  def edit
    @this = find_instance
    fill_drop_down
  end

end
