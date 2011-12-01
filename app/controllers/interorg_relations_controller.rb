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
    @this = InterorgRelation.value_is_not('').order_by(:value, 'desc').paginate(:per_page=>10, :page=>1)
  end

  index_action :list do
    hobo_index InterorgRelation.value_is_not('').order_by(params['sort'].to_sym)
    render :index
  end

end
