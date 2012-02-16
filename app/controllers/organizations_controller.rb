# -*- encoding : utf-8 -*-
class OrganizationsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  autocomplete

  caches_page :show,  :expires_in => 10.minutes
  caches_page :index, :expires_in => 10.minutes

  caches_page :person_to_org_pagination, :expires_in => 20.minutes
  caches_page :interorg_pagination, :expires_in => 20.minutes
  caches_page :financial_pagination, :expires_in => 20.minutes
  caches_page :list, :expires_in => 20.minutes


  def create
    add_new_entities
    if flash[:errors].present?
      redirect_to new_organization_path and return 
    else
      hobo_create
    end
  end

  def update
    render :text => "access denied" unless current_user.administrator? or current_user.editor? or current_user.supervisor?
    add_new_entities    
    redirect_to edit_organization_path(params[:id]) and return if flash[:errors].present?
    @organization = find_instance
    hobo_update
    if @organization.valid?
      OrgHistory.create( :user_id => current_user.id, :organization_id => @organization.id, :parameters => params.inspect ) 
    end
  rescue => e
    logger.info e.backtrace.join("\n")
    logger.info "*********************************************** update org error happened ********************************"
    logger.info e.inspect
  end


  def add_new_entities
    info_source = InformationSource.find_or_create_by_name('ahalo.hu') do |r| r.name = 'ahalo.hu'; r.web = 'http://ahalo.hu' end
    if !params[:organization][:person_to_org_relations].blank?
      params[:organization][:person_to_org_relations].each do |k,p|
        if p[:person].blank?
          flash[:errors] = 'related entity cannot be blank'
        elsif !Person.find_by_name(p[:person])
          first_name = p[:person].split(' ')
          last_name = first_name.shift
          first_name = first_name.join(' ')
          Person.create( :first_name => first_name,
                         :last_name => last_name, 
                         :user_id => current_user.id,
                         :information_source_id => p[:information_source_id].blank? ? info_source.id : p[:information_source_id]
                       )
        end
        if !p[:article_relations].blank?
          p[:article_relations].each do |k,a|
            next if k.to_i == -1
            if a[:article].blank? or !Article.find_by_name( a[:article] )
              if flash[:errors].present?
                flash[:errors] << "\nArticle does not exist for #{p[:person]} with name #{a[:article]}"
              else
                flash[:errors] = "Article does not exist for #{p[:person]} with name #{a[:article]}"
              end
            end
          end
        end
      end
    end
    if !params[:organization][:interorg_relations].blank?
      params[:organization][:interorg_relations].each do |k,o|
        if o[:related_organization].blank?
          flash[:errors] = 'related entity cannot be blank'
        elsif !Organization.find_by_name(o[:related_organization])
          Organization.create(:name => o[:related_organization], 
                              :user_id => current_user.id,
                              :information_source_id => o[:information_source_id].blank? ? info_source.id : o[:information_source_id]
                             )
        end
        if !o[:article_relations].blank?
          o[:article_relations].each do |k,a|
            next if k.to_i == -1
            if a[:article].blank? or !Article.find_by_name( a[:article] )
              if flash[:errors].present?
                flash[:errors] << "\nArticle does not exist for #{o[:related_organization]} with name #{a[:article]}"
              else
                flash[:errors] = "Article does not exist for #{o[:related_organization]} with name #{a[:article]}"
              end
            end
          end
        end
      end
    end
  end

  index_action :person_to_org_pagination do
    @this = find_instance
    return unless @this
    @person_to_orgs = @this.person_to_org_relations.paginate(:per_page=>10, :page=>params[:page])
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
    @this = Organization.relations_counter_is_not(0).order_by(:name)
    respond_to do |format| 
      format.html  { hobo_index( @this, :per_page => 20, :include => :information_source ) }
      format.xml   { render( :xml  => @this ) and return }
      format.json  { render( :json => @this ) and return }
    end
  end

  def show
    @this               = find_instance
    data = []
    @this.interorg_relations.value_is_not(0).limit(20).each do |rel|
      data << { :name =>  (rel.name.scan(/./)[0..48].join('')+'...'), :y =>rel.value }
    end
    respond_to do |format| 
      format.html  { 
        hobo_show @this 
        @h = LazyHighCharts::HighChart.new('pie') do |f|
          f.options[:chart][:defaultSeriesType] = "pie"
          f.options[:title][:text] = "Top tranzakciók"
          f.series(:data=> data)
        end
      }
      format.xml   { render( :xml  => { "data" =>  @this, "interorg_relations"  => @this.interorg_relations, "person_to_org_relations" => @this.person_to_org_relations } ) }
      format.json  { render( :json => { "data"=>  @this,  "interorg_relations"  => @this.interorg_relations, "person_to_org_relations" => @this.person_to_org_relations } ) }
    end
  end

  index_action :query do
    render :json => Organization.name_contains(params[:term]).order_by(:name).limit(40).all(:select=>'id, name').map {|org|
      {:label => "#{org.name} (ID:#{org.id})", :id => org.id}
    }
  end


  index_action :list do
    @organizations = Organization.relations_counter_is_not(0).apply_scopes(:order_by => parse_sort_param(:name, :updated_at)).paginate(:per_page=>20, :page=>params[:page], :include=>:information_source)
  end

  show_action :merge do
    merge_into = find_instance
    to_merge = Organization.find_by_id(params[:organization][:merge_from][:organization].split('(ID:')[1].chop)
    if !to_merge
      flash.now[:error] = "Ez a merge már megtörtént!"
    else
      if merge_into.id == to_merge.id
        flash.now[:error] = "Nem lehet szervezetet önmagával egyesíteni!"
      else
        merged = Organization.merge merge_into, to_merge
        OrgHistory.create( :user_id => current_user.id, :organization_id => merge_into.id, :parameters => "#{params.inspect}, #{merged}") 
        flash.now[:notice] = "#{to_merge.name} kapcsolatai sikeresen hozzáadva!"
      end
    end
    hobo_show merge_into
    render :show
  end
end

