# -*- encoding : utf-8 -*-
class O2oRelationTypesController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def show
    @this = find_instance
    respond_to do |format| 
      format.html  { 
        hobo_show @this do 
          @organizations = this.organizations.paginate(:page => params[:page]) 
        end 
      }
      format.xml   { render(:xml => @this) }
      format.json  { render(:json=> @this) }
    end
  end

end

