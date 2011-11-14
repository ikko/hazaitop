class FrontController < ApplicationController

  hobo_model_controller

  caches_page :index, :expires_in => 4.minutes
  caches_page :impressum, :expires_in => 90.minutes
  caches_page :development, :expires_in => 90.minutes

  def index
    @people        = Person.listed.paginate(:per_page=>10, :page=>params[:page])
    @organizations = Organization.listed.paginate(:per_page=>10, :page=>params[:page])
    @contracts     = Contract.paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :person_pagination do
    @people = Person.apply_scopes(:order_by => parse_sort_param(:interpersonal_relations_count, :person_to_org_relations_count, :updated_at)).paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :org_pagination do
    @organizations = Organization.apply_scopes(:order_by => parse_sort_param(:person_to_org_relations_count, :interorg_relations_count, :updated_at)).paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :contract_pagination do
    @contracts = Contract.apply_scopes(:order_by => parse_sort_param(:contracted_value, :no_of_proposals)).paginate(:per_page=>10, :page=>params[:page])
  end

  def impressum; end

  def development; end

  def summary ; end

  def api ; end

  def search               
    query = params[:query]
    # főoldalről érkező ajaxos keresés
    if request.xhr?
      query = "" unless query.present? 
      @organizations = Organization.search(query, :name).paginate(:per_page=>10, :page=>1)
      @people        = Person.search(query, :last_name, :first_name).paginate(:per_page=>10, :page=>1)
      @litigations   = Litigation.search(query, :name).paginate(:per_page=>10, :page=>1)
      @articles      = Article.search(query, :title).paginate(:per_page=>10, :page=>1)
      render_tags(@organizations+@people+@litigations+@articles, :search_card, :for_type => true) 
    # részletes keresés oldalról érkező html keresés
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
        transaction_conditions = []
        transaction_conditions << ["interorg_relations.value >= ?", params[:amount_from]] if params[:amount_from]
        transaction_conditions << ["interorg_relations.value <= ?", params[:amount_to]] if params[:amount_to]
        transaction_conditions << ["interorg_relations.happened_at >= ?", params[:date_from]] if params[:date_from]
        transaction_conditions << ["interorg_relations.happened_at <= ?", params[:date_to]] if params[:date_to]
        cond = ""
        par = []
        transaction_conditions.each_with_index do |e, i|
          if i.even?
            cond << (i>0 ? " and #{e}" : e)
          else
            par << e
          end
        end
        builded_transaction_conditions = [cond] + par
        @transactions = Organization.search(query, :name).
                                     paginate(:joins=>:interorg_relations, 
                                              :conditions=>builded_transaction_conditions, 
                                              :per_page=>10, 
                                              :page=>1)
      # nem kerestek dátumra
      elsif !params[:date_from].present? && !params[:date_to].present?
        @organizations = Organization.search(query, :name).paginate(:per_page=>10, :page=>1) if params[:organization]
        @people        = Person.search(query, :last_name, :first_name).paginate(:per_page=>10, :page=>1) if params[:person]
        @litigations   = Litigation.search(query, :name).paginate(:per_page=>10, :page=>1) if params[:litigation]
        @articles      = Article.search(query, :title).paginate(:per_page=>10, :page=>1) if params[:article]
      # valamire rákerestek
      else
        person_conditions = []
        organization_conditions = []
        litigation_conditions = []
        person_pars = []
        org_pars = []
        lit_pars = []

        if params[:date_from].present?
          person_conditions << "(person_to_org_relations.start_time >= ? or interpersonal_relations.start_time >= ?)"
          person_pars << params[:date_from]
          person_pars << params[:date_from]

          organization_conditions << "person_to_org_relations.start_time >= ?"
          org_pars << params[:date_from]

          litigation_conditions << "start_time >= ?"
          lit_pars << params[:date_from]
        end
        if params[:date_to].present?
          person_conditions << "(person_to_org_relations.end_time <= ? or interpersonal_relations.end_time <= ?)"
          person_pars << params[:date_to]
          person_pars << params[:date_to]
          organization_conditions << "person_to_org_relations.end_time <= ?"
          org_pars << params[:date_to]
          litigation_conditions << "end_time <= ?"
          lit_pars << params[:date_to]
        end

        cond = ""
        person_conditions.flatten.each_with_index do |e, i|
          cond << (i>0 ? " and #{e}" : e)
        end
        builded_person_conditions = [cond] + person_pars

        cond = ""
        organization_conditions.flatten.each_with_index do |e, i|
          cond << (i>0 ? " and #{e}" : e)
        end
        builded_organization_conditions = [cond] + org_pars

        cond = ""
        litigation_conditions.flatten.each_with_index do |e, i|
          cond << (i>0 ? " and #{e}" : e)
        end
        builded_litigation_conditions = [cond] + org_pars

        @people = params[:person] ? Person.search(query, :last_name, :first_name).
                                           paginate(:joins=>"left outer join person_to_org_relations on person_to_org_relations.person_id = people.id 
                                                             left outer join interpersonal_relations on interpersonal_relations.person_id = people.id", 
                                                    :conditions=>builded_person_conditions,
                                                    :per_page=>10, 
                                                    :page=>1) : Person.limit(0)
        @organizations = params[:organization] ? Organization.search(query, :name).paginate(:joins=>"left outer join person_to_org_relations on person_to_org_relations.organization_id = organizations.id",
                                                                    :conditions=>builded_organization_conditions,
                                                                    :per_page=>10,
                                                                    :page=>1) : Organization.limit(0)
        @litigations = params[:litigation] ? Litigation.search(query, :name).
                                    paginate(:conditions=>builded_litigation_conditions, 
                                             :per_page=>10, 
                                             :page=>1) : Litigation.limit(0)

        # article esetén nem figyeljük a dátum keresést
        @articles = params[:article] ? Article.search(query, :title).paginate(:per_page=>10, :page=>1) : Article.limit(0)
      end
    end
  end
end
