class FrontController < ApplicationController

  hobo_model_controller

  caches_page :index, :expires_in => 4.minutes
  caches_page :impressum, :expires_in => 90.minutes
  caches_page :development, :expires_in => 90.minutes

  def index
    @people        = Person.order_by(:interpersonal_relations_count, 'desc').paginate(:per_page=>10, :page=>params[:page])
    @organizations = Organization.order_by(:person_to_org_relations_count, 'desc').paginate(:per_page=>10, :page=>params[:page])
    @transactions  = InterorgRelation.order_by(:value, 'desc').not_mirror.value_is_not('').paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :person_pagination do
    params[:sort] ||= '-interpersonal_relations_count'
    @people = Person.apply_scopes(:order_by => parse_sort_param(:interpersonal_relations_count, :person_to_org_relations_count, :updated_at)).paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :org_pagination do
    params[:sort] ||= '-person_to_org_relations_count'
    @organizations = Organization.apply_scopes(:order_by => parse_sort_param(:person_to_org_relations_count, :interorg_relations_count, :updated_at)).paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :trans_pagination do
    params[:sort] ||= '-value'
    @transactions = InterorgRelation.value_is_not('').not_mirror.apply_scopes(:order_by=> parse_sort_param(:value, :issued_at)).paginate(:per_page=>10, :include=>[:organization, :related_organization, :o2o_relation_type, {:o2o_relation_type => :pair}], :page=>params[:page])
  end

  def how_it_works; end
  def about; end
  def contact; end
  def impressum; end
  def development; end

  def summary ; end

  def api ; end

  def search               
    query = params[:query] || ""
    # főoldalről érkező ajaxos keresés
    if request.xhr?
      @organizations = Organization.search(query, :name).paginate(:per_page=>10, :page=>params[:page])
      @people        = Person.search(query, :name).paginate(:per_page=>10, :page=>params[:page])
      @litigations   = Litigation.search(query, :name).paginate(:per_page=>10, :page=>params[:page])
      @articles      = Article.search(query, :title).paginate(:per_page=>10, :page=>params[:page])
      render_tags(@organizations+@people+@litigations+@articles, :search_card, :for_type => true) 
    end
  end

  # részletes keresés oldalról érkező html keresés
  def detailed_search
    params[:query] ||= ''
    query = params[:query]
    # ha ajaxos lapozás van
    if params[:block]
      if params[:block]=='transaction'
        @transactions = get_transactions
        render "paginate_transaction" and return
      elsif params[:block]=='person'
        @people = get_people
        render "paginate_person" and return
      elsif params[:block]=='org'
        @organizations = get_organizations
        render "paginate_organization" and return
      elsif params[:block]=='article'
        @articles = get_articles
        render "paginate_article" and return
      elsif params[:block]=='litigation'
        @litigations = get_litigations
        render "paginate_litigation" and return
      end
    else
      # ha nincs params-ba semmi akkor pl a főoldalról jöhetett, ilyenkor az alapbeállításokkal dolgozunk
      if !params[:transaction] && !params[:article] && !params[:person] && !params[:organization] && !params[:litigation]
        params[:article] = true
        params[:person] = true
        params[:organization] = true
        params[:litigation] = true
      end

      # ha tranzakció be van jelölve akkor csak ott keresünk
      if params[:transaction]
        @transactions = get_transactions
      # nem kerestek dátumra
      elsif !params[:date_from].present? && !params[:date_to].present?
        @organizations = params[:organization] ? Organization.search(query, :name).paginate(:per_page=>10, :page=>params[:page]) : Organization.limit(0)
        @people        = params[:person] ? Person.search(query, :name).paginate(:per_page=>10, :page=>params[:page]) : Person.limit(0)
        @litigations   = params[:litigation] ? Litigation.search(query, :name).paginate(:per_page=>10, :page=>params[:page]) : Litigation.limit(0)
        @articles      = params[:article] ? Article.search(query, :title).paginate(:per_page=>10, :page=>params[:page]) : Article.limit(0)
      # valamire rákerestek
      else
        @people = params[:person] ? get_people : Person.limit(0)
        @organizations = params[:organization] ? get_organizations : Organization.limit(0)
        @litigations = params[:litigation] ? get_litigations : Litigation.limit(0)
        # article esetén nem figyeljük a dátum keresést
        @articles = params[:article] ? get_articles : Article.limit(0)
      end
    end
  end

private
  def get_transactions
    transaction_conditions = []
    transaction_conditions << ["interorg_relations.value != ?", 0]
    transaction_conditions << ["interorg_relations.value >= ?", params[:amount_from]] if params[:amount_from].present?
    transaction_conditions << ["interorg_relations.value <= ?", params[:amount_to]] if params[:amount_to].present?
    transaction_conditions << ["interorg_relations.issued_at >= ?", params[:date_from]] if params[:date_from].present?
    transaction_conditions << ["interorg_relations.issued_at <= ?", params[:date_to]] if params[:date_to].present?
    cond = ""
    par = []
    transaction_conditions.flatten.each_with_index do |e, i|
      if i.even?
        cond << (i>0 ? " and #{e}" : e)
      else
        par << e
      end
    end
    builded_transaction_conditions = [cond] + par
    InterorgRelation.search(params[:query], :name).
                     paginate(:include=>[:contract, :tender, :organization, :related_organization],
                              :conditions=>builded_transaction_conditions, 
                              :per_page=>10, 
                              :page=>params[:page])
  end

  def get_people
      person_conditions = []
      person_pars = []
      
      if params[:date_from].present?
        person_conditions << "(person_to_org_relations.start_time >= ? or interpersonal_relations.start_time >= ?)"
        person_pars << params[:date_from]
        person_pars << params[:date_from]

      end
      if params[:date_to].present?
        person_conditions << "(person_to_org_relations.end_time <= ? or interpersonal_relations.end_time <= ?)"
        person_pars << params[:date_to]
        person_pars << params[:date_to]
      end

      cond = ""
      person_conditions.flatten.each_with_index do |e, i|
        cond << (i>0 ? " and #{e}" : e)
      end
      builded_person_conditions = [cond] + person_pars
      Person.search(params[:query], :name).
             paginate(:joins=>"left outer join person_to_org_relations on person_to_org_relations.person_id = people.id 
                               left outer join interpersonal_relations on interpersonal_relations.person_id = people.id", 
                      :conditions=>builded_person_conditions,
                      :per_page=>10,
                      :page=>params[:page])
  end

  def get_organizations
      organization_conditions = []
      org_pars = []

      if params[:date_from].present?
        organization_conditions << "person_to_org_relations.start_time >= ? and interorg_relations.issued_at >=?"
        org_pars << params[:date_from]
        org_pars << params[:date_from]
      end
      if params[:date_to].present?
        organization_conditions << "person_to_org_relations.end_time <= ? and interorg_relations.isseud_at <=?"
        org_pars << params[:date_to]
        org_pars << params[:date_to]
      end

      cond = ""
      organization_conditions.flatten.each_with_index do |e, i|
        cond << (i>0 ? " and #{e}" : e)
      end
      builded_organization_conditions = [cond] + org_pars
      Organization.search(params[:query], :name).
                   paginate(:joins=>"left outer join person_to_org_relations on person_to_org_relations.organization_id = organizations.id
                                     left outer join interorg_relations on interorg_relations.organization_id = organizations.id",
                            :conditions=>builded_organization_conditions,
                            :per_page=>10,
                            :page=>params[:page])
  end

  def get_litigations
      litigation_conditions = []
      lit_pars = []

      if params[:date_from].present?
        litigation_conditions << "start_time >= ?"
        lit_pars << params[:date_from]
      end
      if params[:date_to].present?
        litigation_conditions << "end_time <= ?"
        lit_pars << params[:date_to]
      end

      cond = ""
      litigation_conditions.flatten.each_with_index do |e, i|
        cond << (i>0 ? " and #{e}" : e)
      end
      builded_litigation_conditions = [cond] + org_pars
      Litigation.search(params[:query], :name).
                 paginate(:conditions=>builded_litigation_conditions, 
                          :per_page=>10, 
                          :page=>params[:page])
  end

  def get_articles
    Article.search(params[:query], :title).paginate(:per_page=>10, :page=>params[:page])
  end
end
