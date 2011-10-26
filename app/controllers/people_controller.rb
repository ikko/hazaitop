class PeopleController < ApplicationController

  hobo_model_controller

  auto_actions :all 

  autocomplete

#  caches_page :show,  :expires_in => 4.minutes
#  caches_page :index, :expires_in => 4.minutes

  def update
    hobo_update do
      PersonHistory.create( :user_id => current_user.id, :person_id => @this.id ) if @this.valid?
    end
  end

  index_action :search do
    query = params[:query] || ""
    @people = Person.search(query, :name).paginate(:per_page=>10, :page=>params[:page])
  end

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
    @this = Person.listed
    respond_to do |format| 
      format.html  { hobo_index( @this, :per_page => 10 ) }
      format.xml   { render( :xml  => @this ) and return }
      format.json  { render( :json => @this ) and return }
    end
  end

  def show
    @this = find_instance
    respond_to do |format| 
      format.html  { hobo_show @this }
       format.xml  { render( :xml => { "data" =>  @this, "interpersonal_relations" => @this.interpersonal_relations, "person_to_org_relations" => @this.person_to_org_relations }  ) }
      format.json  { render( :json => { "data"=>  @this, "interpersonal_relations"  => @this.interpersonal_relations, "person_to_org_relations" => @this.person_to_org_relations } ) }
    end
  end

  index_action :query do
    render :json => Person.name_contains(params[:term]).order_by(:name).limit(100).all(:select=>'id, name').map {|person|
      {:label => person.name, :id => person.id}
    }
  end

  index_action :list do
    hobo_index Person.order_by(params['sort'].to_sym)
    render :index
  end

  private

  def fill_local_drop_down
    @people_except_this = Person.all-[@this]
  end

end
