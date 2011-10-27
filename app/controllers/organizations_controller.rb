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

  index_action :search do
    query = params[:query] || ""
    @organizations = Organization.search(query, :name).paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :person_to_org_pagination do
    @this = find_instance
    return unless @this
    @person_to_orgs = @this.interorg_relations.paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :interorg_pagination do
    @this = find_instance
    return unless @this
    @interorgs = @this.interorg_relations.paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :financial_pagination do
    @this = find_instance
    return unless @this
    @financials = @this.org_histories.paginate(:per_page=>10, :page=>params[:page])
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

  index_action :list do
    hobo_index Organization.order_by(params['sort'].to_sym)
    render :index
  end

  show_action :merge do
    merge_into = find_instance
    to_merge = Organization.find_by_name(params[:organization][:merge_from])
    Organization.merge merge_into, to_merge
    flash.now[:notice] = "#{to_merge.name} has been successfully merged into #{merge_into.name}!"
    hobo_show merge_into
    render :show
  end
end
