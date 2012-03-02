# -*- encoding : utf-8 -*-
class PeopleController < ApplicationController

  hobo_model_controller

  auto_actions :all 

  autocomplete

  caches_page :show,  :expires_in => 10.minutes
  caches_page :index, :expires_in => 10.minutes

  caches_page :person_to_org_pagination, :expires_in => 20.minutes
  caches_page :interorg_pagination, :expires_in => 20.minutes
  caches_page :history_pagination, :expires_in => 20.minutes
  caches_page :list, :expires_in => 20.minutes

#  def complete_name
#    hobo_completions :name, Person.auto(
#  end

#  named_scope :auto, lambda { { :conditions => { :locale => I18n.locale } } }


  def create
    add_new_entities
    if flash[:errors].present?
      redirect_to new_person_path and return 
    else
      hobo_create
    end
  end

  index_action :closer
  show_action :closest do
    @a = Person.find(params[:interpersonal_relation][:person].split('(ID:')[1].chop)
    @b = Person.find(params[:interpersonal_relation][:related_person].split('(ID:')[1].chop)
    @this = @a.path_to(@b) if @a and @b
  end

  def update
    render :text => "access denied" unless current_user.administrator? or current_user.editor? or current_user.supervisor? # mivel nincs hobo permi check ilyenkor...
    add_new_entities    
    redirect_to edit_person_path(params[:id]) and return if flash[:errors].present?
    @person = find_instance
    hobo_update 
    if @person.valid?
      PersonHistory.create( :user_id => current_user.id, :person_id => @person.id, :parameters => params.inspect) 
    end
  rescue => e
    logger.info e.backtrace.join("\n")
    logger.info "*********************************************** update person error happened ********************************"
    logger.info e.inspect
  end

  def add_new_entities
    info_source = InformationSource.find_or_create_by_name('ahalo.hu') do |r| r.name = 'ahalo.hu'; r.web = 'http://ahalo.hu' end
    if !params[:person][:personal_relations].blank?
      params[:person][:personal_relations].each do |k,p|
        if p[:related_person].blank?
          flash[:errors] = 'related entity cannot be blank'
        elsif !Person.find_by_name(p[:related_person])
          first_name = p[:related_person].split(' ')
          last_name = first_name.shift
          first_name = first_name.join(' ')
          Person.create( :first_name => first_name,
                         :last_name => last_name, 
                         :user_id => current_user.id,
                         :information_source_id => p[:information_source_id].blank? ? info_source.id : p[:information_source_id]
                       )
        end
      end
    end
    if !params[:person][:person_to_org_relations].blank?
      params[:person][:person_to_org_relations].each do |k,o|
        if o[:organization].blank?
          flash[:errors] = 'related entity cannot be blank'
        elsif !Organization.find_by_name(o[:organization])
          Organization.create(:name => o[:organization], 
                              :user_id => current_user.id,
                              :information_source_id => p[:information_source_id].blank? ? info_source.id : p[:information_source_id]
                             )
        end
      end
    end

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
    @this = Person.relations_counter_is_not(0).order_by(:order_name)
    respond_to do |format| 
      format.html  { hobo_index( @this, :per_page => 20, :include => :information_source ) }
      format.xml   { render( :xml  => @this ) and return }
      format.json  { render( :json => @this ) and return }
    end
  end

  index_action :interpersonal_pagination do
    @this = find_instance
    return unless @this
    @interpersons = @this.interpersonal_relations.paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :person_to_org_pagination do
    @this = find_instance
    return unless @this
    @person_to_orgs = @this.person_to_org_relations.paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :history_pagination do
    @this = find_instance
    return unless @this
    @histories = @this.person_histories.paginate(:per_page=>10, :page=>params[:page])
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
    render :json => Person.name_contains(params[:term]).order_by(:name).limit(40).all(:select=>'id, name').map {|person|
      {:label => "#{person.name} (ID:#{person.id})", :id => person.id}
    }
  end

  index_action :list do
    @people = Person.relations_counter_is_not(0).apply_scopes(:order_by => parse_sort_param(:name, :updated_at)).paginate(:per_page=>20, :page=>params[:page], :include => :information_source)
  end

  show_action :merge do
    merge_into = find_instance
    to_merge = Person.find_by_id(params[:person][:merge_from][:person].split('(ID:')[1].chop)
    if !to_merge
      flash.now[:error] = "Ez a merge már megtörtént!"
    else
      if merge_into.id == to_merge.id
        flash.now[:error] = "Nem lehet személyt önmagával egyesíteni!"
      else
        merged = Person.merge merge_into, to_merge
        PersonHistory.create( :user_id => current_user.id, :person_id => merge_into.id, :parameters => "#{params.inspect}, #{merged}")
        flash.now[:notice] = "#{to_merge.name} kapcsolatai sikeresen hozzáadva!"
      end
    end
    hobo_show merge_into
    render :show
  end

  private

  def fill_local_drop_down
    @people_except_this = Person.all-[@this]
  end

end

