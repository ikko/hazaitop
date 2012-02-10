class DetailedSearchesController < ApplicationController

  hobo_model_controller

  auto_actions :index, :create

  caches_page :create, :expires_in => 10.minutes
  caches_page :new, :expires_in => 10.minutes
  caches_page :index, :expires_in => 10.minutes


  def create
    index
    render :action => :index
  end

  def index

    @detailed_search = DetailedSearch.new params[:detailed_search]

    @detailed_search.query   ||= params[:query] ||= ""
    @detailed_search.address ||= params[:address] ||= ""

    @detailed_search.query = "" if @detailed_search.query == "Keresés"

     if @detailed_search.query.blank?     and 
        @detailed_search.address.blank?   and
        @detailed_search.date_from.blank? and
        @detailed_search.date_to.blank?   and
        @detailed_search.person       == true and
        @detailed_search.organization == true and
        @detailed_search.article      == true and
        @detailed_search.litigation   == true and 
        @detailed_search.transaction.blank? and
        @detailed_search.relations.blank?   and
        @detailed_search.amount_from.blank? and
        @detailed_search.amount_to.blank?     

       @empty_search = true
     else
       @empty_search = false
     end

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
      if !@empty_search
        # ha tranzakció be van jelölve akkor csak ott keresünk
        if @detailed_search.transaction?
          @transactions = get_transactions
          @contracts    = get_contracts
          # nem kerestek dátumra
        elsif !@detailed_search.date_from.present? && !@detailed_search.date_to.present?
          @organizations = @detailed_search.organization? ? Organization.search(@detailed_search.query, :name).search(@detailed_search.address, :address).
            paginate(build_paginate_params_for(:organization)) : 
            Organization.limit(0)
          @people        = @detailed_search.person? ? Person.search(@detailed_search.query, :name).search(@detailed_search.address, :address).
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
        r = Person.find(@people.try.first.try.id) if @people.try.first
        r.try.increment! :search_result_count
        r = Organization.find(@organizations.try.first.try.id) if @organizations.try.first
        r.try.increment! :search_result_count
        r = Litigation.find(@litigations.try.first.try.id) if @litigations.try.first
        r.try.increment! :search_result_count
        r = Article.find(@articles.try.first.try.id) if @articles.try.first
        r.try.increment! :search_result_count
        r  = InterorgRelation.find(@transactions.try.first.try.id) if @transactions.try.first
        r.try.increment! :search_result_count
      end
    end
  end

private
  def build_paginate_params_for relation
    pag_params = {:per_page=>10, :page=>params[:page], :conditions=>{}, :joins=>""}
    if relation.to_sym == :organization && @detailed_search.organization?
      pag_params[:conditions].merge!({:relations_bit => true})
      if @detailed_search.place_of_births.present?
        pag_params[:conditions].merge!({:city=>@detailed_search.place_of_births.*.name})
      end
      if @detailed_search.sectors.present?
        pag_params[:conditions].merge!({:sector_id => @detailed_search.sectors})
      end
      if @detailed_search.relations.present?
        # TODO itt a pag_params[:joins] most mindig felül van csapva!                
        if @detailed_search.relations.first.p2o_relation_types.present?
          pag_params[:joins] += "left outer join person_to_org_relations on person_to_org_relations.organization_id=organizations.id "
          pag_params[:conditions].merge!({:"person_to_org_relations.p2o_relation_type_id"=>@detailed_search.relations.first.p2o_relation_types})
        end
        if @detailed_search.relations.first.o2o_relation_types.present?
          # TODO a relatedet is bejoin-onljuk
          pag_params[:joins] += "left outer join interorg_relations on interorg_relations.organization_id=organizations.id "
          pag_params[:conditions].merge!({:"interorg_relations.o2o_relation_type_id"=>@detailed_search.relations.first.o2o_relation_types})
        end
      end
      if @detailed_search.activities.present?
        pag_params[:joins] += "left outer join activity_assocs on activity_assocs.organization_id=organizations.id "
        pag_params[:conditions].merge!({:"activity_assocs.activity_id"=>@detailed_search.activities})
      end
    end
    if relation.to_sym == :person && @detailed_search.person?
      pag_params[:conditions].merge!({:relations_bit => true})
      if @detailed_search.place_of_births.present?
        pag_params[:conditions].merge!({:city=>@detailed_search.place_of_births.*.name})
      end
      if @detailed_search.relations.present?
        if @detailed_search.relations.first.p2p_relation_types.present?
          pag_params[:joins] += "left outer join interpersonal_relations on interpersonal_relations.person_id=people.id "
          pag_params[:conditions].merge!({:"interpersonal_relations.p2p_relation_type_id"=>@detailed_search.relations.first.p2p_relation_types})
        end
        if @detailed_search.relations.first.p2o_relation_types.present?
          pag_params[:joins] += "left outer join person_to_org_relations on person_to_org_relations.person_id=people.id "
          pag_params[:conditions].merge!({:"person_to_org_relations.p2o_relation_type_id"=>@detailed_search.relations.first.p2o_relation_types})
        end
      end
    end
    pag_params[:joins] = nil if pag_params[:joins].strip.empty?
    pag_params
  end


  def get_contracts
    contract_conditions = []
    contract_conditions << ["contracts.value != ?", 0]
    contract_conditions << ["contracts.value >= ?", @detailed_search.amount_from] if @detailed_search.amount_from.present?
    contract_conditions << ["contracts.value <= ?", @detailed_search.amount_to] if @detailed_search.amount_to.present?
    contract_conditions << ["contracts.issued_at >= ?", @detailed_search.date_from] if @detailed_search.date_from.present?
    contract_conditions << ["contracts.issued_at <= ?", @detailed_search.date_to] if @detailed_search.date_to.present?
    cond = ""
    par = []
    contract_conditions.flatten.each_with_index do |e, i|
      if i.even?
        cond << (i>0 ? " and #{e}" : e)
      else
        par << e
      end
    end
    builded_contract_conditions = [cond] + par
    Contract.search(@detailed_search.query, :name).
             search(@detailed_search.address, :place_of_performance).
             search(@detailed_search.subject, :subject_and_qty).
                     paginate(
                              :conditions=>builded_contract_conditions, 
                              :per_page=>10, 
                              :page=>params[:page])
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
    InterorgRelation.search(@detailed_search.query, :name).search(@detailed_search.address, :address).
                     paginate(:include=>[:contract, :tender, :organization, :related_organization],
                              :conditions=>builded_transaction_conditions, 
                              :per_page=>10, 
                              :page=>params[:page])
  end

  def get_people
      person_conditions = [ "(people.relations_bit = ?)" ]
      person_pars = [ true ]
      
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

      if @detailed_search.relations.present?
        if @detailed_search.relations.first.p2o_relations.present?
          person_conditions << "(p2o_relations.p2o_relation_type_id in (?))"
          person_pars << @detailed_search.relations.first.p2o_relations.*.id
        end
        if @detailed_search.relations.first.p2p_relations.present?
          person_conditions << "(p2p_relations.p2p_relation_type_id in (?))"
          person_pars << @detailed_search.relations.first.p2p_relations.*.id
        end
      end

      cond = ""
      person_conditions.flatten.each_with_index do |e, i|
        cond << (i>0 ? " and #{e}" : e)
      end
      builded_person_conditions = [cond] + person_pars
      Person.search(@detailed_search.query, :name).search(@detailed_search.address, :address).
             paginate(:select=>"distinct people.* ",
                      :joins=>"left outer join person_to_org_relations on person_to_org_relations.person_id = people.id 
                               left outer join interpersonal_relations on interpersonal_relations.person_id = people.id", 
                      :conditions=>builded_person_conditions,
                      :per_page=>10,
                      :page=>params[:page])
  end

  def get_organizations
      organization_conditions = [ "(organizations.relations_bit = ?)"  ]
      org_pars = [ true ]

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
        organization_conditions << "(activity_assocs.activity_id in (?))"
        org_pars << @detailed_search.activities.*.id
      end

      if @detailed_search.relations.present?
        if @detailed_search.relations.first.p2o_relation_types.present?
          organization_conditions << "(p2o_relations.p2o_relation_type_id in (?))"
          org_pars << @detailed_search.relations.first.p2o_relation_types.*.id
        end
        if @detailed_search.relations.first.o2o_relation_types.present?
          organization_conditions << "(o2o_relations.o2o_relation_type_id in (?))"
          org_pars << @detailed_search.relations.first.o2o_relation_types.*.id
        end
      end

      cond = ""
      organization_conditions.flatten.each_with_index do |e, i|
        cond << (i>0 ? " and #{e}" : e)
      end
      builded_organization_conditions = [cond] + org_pars
      Organization.search(@detailed_search.query, :name).search(@detailed_search.address, :address).
                   paginate(:select=>"distinct organizations.* ",
                            :joins=>"left outer join interorg_relations on interorg_relations.organization_id = organizations.id
                                     left outer join activity_assocs on activity_assocs.organization_id=organizations.id
                                     left outer join person_to_org_relations on person_to_org_relations.organization_id = organizations.id",
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
