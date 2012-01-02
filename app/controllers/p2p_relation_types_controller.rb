class P2pRelationTypesController < ApplicationController

  caches_page :show, :expires_in => 5.minutes

  hobo_model_controller

  auto_actions :all

  def show
    @this = find_instance
    respond_to do |format| 
      format.html  { hobo_show @this }
      format.xml   { render(:xml => @this) }
      format.json  { render(:json=> @this) }
    end
  end


end
