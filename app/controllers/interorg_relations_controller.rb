# -*- encoding : utf-8 -*-
class InterorgRelationsController < ApplicationController

  hobo_model_controller

  auto_actions :all #, :index, :show

  def show
    @this = find_instance
    respond_to do |format| 
      format.html  { hobo_show @this }
      format.xml   { render(:xml => @this) }
      format.json  { render(:json=> @this) }
    end
  end

  def index
    @this = InterorgRelation.not_mirror.value_is_not('').order_by(:value, 'desc')
    params[:sort] ||= "value"
    respond_to do |format| 
      format.html  { hobo_index( @this, :per_page => 20, :include => [:tender, :contract] ) }
      format.xml   { render( :xml  => @this ) and return }
      format.json  { render( :json => @this ) and return }
    end
  end

  index_action :list do
    @transactions = InterorgRelation.not_mirror.value_is_not('').apply_scopes(:order_by => parse_sort_param(:value, :name, :updated_at)).paginate(:per_page=>20, :page=>params[:page], :include=>[:tender, :contract])
  end

end

