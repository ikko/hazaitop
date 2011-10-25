class ArticlesController < ApplicationController

  hobo_model_controller

  auto_actions :all

  autocomplete :title

  def new
    fill_drop_down
    hobo_new
  end

  def edit
    @this = find_instance
    fill_drop_down
  end

  def show
    @this = find_instance

    respond_to do |format| 
      format.html  { hobo_show @this }
      format.xml   { render(:xml => @this) }
      format.json  { render(:json=> @this) }
    end
  end


end
