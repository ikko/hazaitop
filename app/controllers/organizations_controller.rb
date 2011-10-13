class OrganizationsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  autocomplete

#  caches_page :show,  :expires_in => 4.minutes
#  caches_page :index, :expires_in => 4.minutes

  def update
    hobo_update do
      OrgHistory.create( :user_id => current_user.id, :organization_id => @this.id ) if @this.valid?
    end
  end

  def index
    @this = Organization.listed
    respond_to do |format| 
      format.html  { hobo_index( @this, :per_page => 10 ) }
      format.xml   { render( :xml  => @this ) and return }
      format.json  { render( :json => @this ) and return }
    end
  end

  def show
    @this               = find_instance
    @interorg_size      = @this.interorg_relations.size
    @person_to_org_size = @this.person_to_org_relations.size
    @financials_size    = @this.financials.size
    respond_to do |format| 
      format.html  { hobo_show @this }
      format.xml   { render( :xml  => { "data" =>  @this, "interorg_relations"  => @this.interorg_relations, "person_to_org_relations" => @this.person_to_org_relations } ) }
      format.json  { render( :json => { "data"=>  @this,  "interorg_relations"  => @this.interorg_relations, "person_to_org_relations" => @this.person_to_org_relations } ) }
    end
  end

  index_action :query do
    render :json => Organization.name_contains(params[:term]).order_by(:name).limit(100).all(:select=>'id, name').map {|org|
      {:label => org.name, :id => org.id}
    }
  end
end
