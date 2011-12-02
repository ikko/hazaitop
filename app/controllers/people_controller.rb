class PeopleController < ApplicationController

  hobo_model_controller

  auto_actions :all 

  autocomplete

#  caches_page :show,  :expires_in => 4.minutes
#  caches_page :index, :expires_in => 4.minutes

  def create
    add_new_entities
    if flash[:errors].present?
      redirect_to new_person_path and return 
    else
      hobo_create
    end
  end

  def update
    render :text => "access denied" unless current_user.administrator? or current_user.editor? or current_user.supervisor?
    logger.info "========================================================== 1 =="
    add_new_entities    
    logger.info "========================================================== 2 =="
    logger.info params.inspect
    redirect_to edit_person_path(params[:id]) and return if flash[:errors].present?
    logger.info "========================================================== 3 =="
    @person = find_instance
    logger.info "========================================================== 4 =="
    logger.info params['person'].inspect
    @person.update_attributes params['person']
    logger.info "========================================================== 5 =="
    if @person.valid?
    logger.info "========================================================== 6 =="
      PersonHistory.create( :user_id => current_user.id, :person_id => @person.id ) 
    logger.info "========================================================== 7 =="
      redirect_to person_path( @person.id )
    logger.info "========================================================== 8 =="
    else
      render :action => :edit
    end

    logger.info "========================================================== 9 =="
  rescue => e
    logger.info e.backtrace.join("\n")
    logger.info "*********************************************** update person error happened ********************************"
    logger.info e.inspect
=begin
    hobo_update do
      PersonHistory.create( :user_id => current_user.id, :person_id => @this.id ) if @this.valid?
      logger.info @this.inspect
      logger.info @this.valid?
    end
=end
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
        if !p[:article_relations].blank?
          p[:article_relations].each do |k,a|
            next if k.to_i == -1
            if a[:article].blank? or !Article.find_by_title( a[:article] )
              if flash[:errors].present?
                flash[:errors] << "\nArticle does not exist for #{p[:related_person]} with title #{a[:article]}"
              else
                flash[:errors] = "Article does not exist for #{p[:related_person]} with title #{a[:article]}"
              end
            end
          end
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
        if !o[:article_relations].blank?
          o[:article_relations].each do |k,a|
            next if k.to_i == -1
            if a[:article].blank? or !Article.find_by_title( a[:article] )
              if flash[:errors].present?
                flash[:errors] << "\nArticle does not exist for #{o[:organization]} with title #{a[:article]}"
              else
                flash[:errors] = "Article does not exist for #{o[:organization]} with title #{a[:article]}"
              end
            end
          end
        end
      end
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
    @this = Person.order_by(:interpersonal_relations_count, 'desc')
    respond_to do |format| 
      format.html  { hobo_index( @this, :per_page => 10 ) }
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
    render :json => Person.name_contains(params[:term]).order_by(:name).limit(100).all(:select=>'id, name').map {|person|
      {:label => person.name, :id => person.id}
    }
  end

  index_action :list do
    hobo_index Person.order_by(params['sort'].to_sym), :per_page=>10
    render :index
  end

  private

  def fill_local_drop_down
    @people_except_this = Person.all-[@this]
  end

end
