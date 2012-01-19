class DetailedSearchesController < ApplicationController

  hobo_model_controller

  auto_actions :index, :create

  def create
    index
    render :action => :index
  end

  def index

    @detailed_search = DetailedSearch.new params[:detailed_search]

    @detailed_search.query ||= ""
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
      # ha tranzakció be van jelölve akkor csak ott keresünk
      if @detailed_search.transaction?
        @transactions = get_transactions
      # nem kerestek dátumra
      elsif !@detailed_search.date_from.present? && !@detailed_search.date_to.present?
        @organizations = @detailed_search.organization? ? Organization.search(@detailed_search.query, :name).
                                                                       paginate(build_paginate_params_for(:organization)) : 
                                                          Organization.limit(0)
        @people        = @detailed_search.person? ? Person.search(@detailed_search.query, :name).
                                                           paginate(build_paginate_params_for(:person)) : 
                                                    Person.limit(0)
        @litigations   = @detailed_search.litigation? ? Litigation.search(@detailed_search.query, :name).
                                                                   paginate(:per_page=>10, :page=>params[:page]) : 
                                                        Litigation.limit(0)
        @articles      = @detailed_search.article? ? Article.search(@detailed_search.query, :name).
                                                             paginate(:per_page=>10, :page=>params[:page]) : 
                                                     Article.limit(0)
      # valamire rákerestek
      else
        @people = @detailed_search.person? ? get_people : Person.limit(0)
        @organizations = @detailed_search.organization? ? get_organizations : Organization.limit(0)
        @litigations = @detailed_search.litigation? ? get_litigations : Litigation.limit(0)
        # article esetén nem figyeljük a dátum keresést
        @articles = @detailed_search.article? ? get_articles : Article.limit(0)
      end
      # statok:
      unless @detailed_search.query.strip.empty?
        @people.try.first.try.incremen!t :search_result_count
        @organizations.try.first.try.increment! :search_result_count
        @litigations.try.first.try.increment! :search_result_count
        @articles.try.first.try.increment! :search_result_count
        @transactions.try.first.try.increment! :search_result_count
      end
    end
  end

private
  def build_paginate_params_for relation
    pag_params = {:per_page=>10, :page=>params[:page], :conditions=>{}}
    if relation.to_sym == :organization && @detailed_search.organization?
      if @detailed_search.place_of_births.present?
        pag_params[:conditions].merge!({:city=>@detailed_search.place_of_births.*.name})
      end
      if @detailed_search.sectors.present?
        pag_params[:conditions].merge!({:sector_id => @detailed_search.sectors})
      end
      if @detailed_search.activities.present?
        pag_params[:joins] = "left outer join activity_assocs on activity_assocs.organization_id=organizations.id"
        pag_params[:conditions].merge!({:"activity_assocs.activity_id"=>@detailed_search.activities})
      end
    end
    if relation.to_sym == :person && @detailed_search.person?
      if @detailed_search.place_of_births.present?
        pag_params[:conditions].merge!({:city=>@detailed_search.place_of_births.*.name})
      end
    end
    pag_params
  end

  def get_transactions
    transaction_conditions = []
    transaction_conditions << ["interorg_relations.value != ?", 0]
    transaction_conditions << ["interorg_relations.value >= ?", @detailed_search.amount_from] if @detailed_search.amount_from.present?
    transaction_conditions << ["interorg_relations.value <= ?", @detailed_search.amount_to] if @detailed_search.amount_to.present?
    transaction_conditions << ["interorg_relations.issued_at >= ?", @detailed_search.date_from] if @detailed_search.date_from.present?
    transaction_conditions << ["interorg_relations.issued_at <= ?", @detailed_search.date_to] if @detailed_search.date_to.present?
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
    InterorgRelation.search(@detailed_search.query, :name).
                     paginate(:include=>[:contract, :tender, :organization, :related_organization],
                              :conditions=>builded_transaction_conditions, 
                              :per_page=>10, 
                              :page=>params[:page])
  end

  def get_people
      person_conditions = []
      person_pars = []
      
      if @detailed_search.date_from.present?
        person_conditions << "(person_to_org_relations.start_time >= ? or interpersonal_relations.start_time >= ?)"
        person_pars << @detailed_search.date_from
        person_pars << @detailed_search.date_from

      end
      if @detailed_search.date_to.present?
        person_conditions << "(person_to_org_relations.end_time <= ? or interpersonal_relations.end_time <= ?)"
        person_pars << @detailed_search.date_to
        person_pars << @detailed_search.date_to
      end

      if @detailed_search.place_of_births.present?
        person_conditions << "(people.city in (?))"
        person_pars << @detailed_search.place_of_births.*.name
      end

      cond = ""
      person_conditions.flatten.each_with_index do |e, i|
        cond << (i>0 ? " and #{e}" : e)
      end
      builded_person_conditions = [cond] + person_pars
      Person.search(@detailed_search.query, :name).
             paginate(:select=>"distinct people.* ",
                      :joins=>"left outer join person_to_org_relations on person_to_org_relations.person_id = people.id 
                               left outer join interpersonal_relations on interpersonal_relations.person_id = people.id", 
                      :conditions=>builded_person_conditions,
                      :per_page=>10,
                      :page=>params[:page])
  end

  def get_organizations
      organization_conditions = []
      org_pars = []

      if @detailed_search.date_from.present?
        organization_conditions << "person_to_org_relations.start_time >= ? and interorg_relations.issued_at >=?"
        org_pars << @detailed_search.date_from
        org_pars << @detailed_search.date_from
      end

      if @detailed_search.date_to.present?
        organization_conditions << "person_to_org_relations.end_time <= ? and interorg_relations.isseud_at <=?"
        org_pars << @detailed_search.date_to
        org_pars << @detailed_search.date_to
      end

      if @detailed_search.place_of_births.present?
        organization_conditions << "(organizations.city in (?))"
        org_pars << @detailed_search.place_of_births.*.name
      end

      if @detailed_search.sectors.present?
        organization_conditions << "(organizations.sector_id in (?))"
        org_pars << @detailed_search.sectors.*.id
      end

      if @detailed_search.activities.present?
        organizaion_conditions << "(activity_assocs.activity_id in (?))"
        org_pars << @detailed_search.activities.*.id
      end

      cond = ""
      organization_conditions.flatten.each_with_index do |e, i|
        cond << (i>0 ? " and #{e}" : e)
      end
      builded_organization_conditions = [cond] + org_pars
      Organization.search(@detailed_search.query, :name).
                   paginate(:select=>"distinct organizations.* ",
                            :joins=>"left outer join person_to_org_relations on person_to_org_relations.organization_id = organizations.id
                                     left outer join interorg_relations on interorg_relations.organization_id = organizations.id
                                     left outer join activity_assocs on activity_assocs.organization_id=organizations.id",
                            :conditions=>builded_organization_conditions,
                            :per_page=>10,
                            :page=>params[:page])
  end

  def get_litigations
      litigation_conditions = []
      lit_pars = []

      if @detailed_search.date_from.present?
        litigation_conditions << "start_time >= ?"
        lit_pars << @detailed_search.date_from
      end
      if @detailed_search.date_to.present?
        litigation_conditions << "end_time <= ?"
        lit_pars << @detailed_search.date_to
      end

      cond = ""
      litigation_conditions.flatten.each_with_index do |e, i|
        cond << (i>0 ? " and #{e}" : e)
      end
      builded_litigation_conditions = [cond] + org_pars
      Litigation.search(@detailed_search.query, :name).
                 paginate(:conditions=>builded_litigation_conditions, 
                          :per_page=>10, 
                          :page=>params[:page])
  end

  def get_articles
    Article.search(@detailed_search.query, :name).paginate(:per_page=>10, :page=>params[:page])
  end
end
