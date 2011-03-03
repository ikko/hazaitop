class PeopleController < ApplicationController

  hobo_model_controller

  auto_actions :all 

  autocomplete

#  caches_page :show,  :expires_in => 4.minutes
#  caches_page :index, :expires_in => 4.minutes

  def index
    hobo_index Person.listed, :per_page => 10
  end

  index_action :query do
    render :json => Person.name_contains(params[:term]).order_by(:name).limit(100).all(:select=>'id, name').map {|person|
      {:label => person.name, :id => person.id}
    }
  end
end
