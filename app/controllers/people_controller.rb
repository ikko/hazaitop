class PeopleController < ApplicationController

  hobo_model_controller

  auto_actions :all 

  autocomplete

#  caches_page :show,  :expires_in => 4.minutes
#  caches_page :index, :expires_in => 4.minutes

  def edit
    @this = find_instance
    fill_drop_down
    fill_local_drop_down
  end

  def new
    fill_drop_down
    fill_local_drop_down
    hobo_new
  end

  def index
    hobo_index Person.listed, :per_page => 10
  end

  index_action :query do
    render :json => Person.name_contains(params[:term]).order_by(:name).limit(100).all(:select=>'id, name').map {|person|
      {:label => person.name, :id => person.id}
    }
  end

  private

  def fill_local_drop_down
    @people_except_this = Person.all-[@this]
  end

end
