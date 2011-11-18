class SiteSearchController < ApplicationController

  hobo_controller

  def generate_node(source, source_type)
    node = {}
    no_data = 'Nincs adat'
    node[:id] = "#{source_type}#{source.id}"
    if source_type == 'p'
      node[:shape] = 'CIRCLE'
      node[:bornAt] = source.born_at ? source.born_at.to_s : no_data
      node[:mothersName] = source.mothers_name.present? ? source.mothers_name : no_data
    elsif source_type == 'o'
      node[:shape] = 'RECTANGLE'
      node[:foundedAt] = source.founded_at ? source.founded_at.to_s : no_data
      node[:address] = source.city.present? || source.street.present? ? "#{source.city} #{source.street}".strip : no_data
      if source.recent_financial_year
        node[:year] = source.recent_financial_year.year
        node[:turnover] = source.recent_financial_year.turnover
        node[:balance] = source.recent_financial_year.balance_sheet_total
      else
        node[:year] = no_data
        node[:turnover] = no_data
        node[:balance] = no_data
      end
    elsif source_type == 'l'
      node[:shape] = 'DIAMOND'
      node[:startTime] = source.start_time ? source.start_time.to_s : no_data
      node[:endTime] = source.end_time ? source.end_time.to_s : no_data
    end
    node[:informationSource] = source.information_source
    node[:label] = source.name.gsub(', ', "\n").gsub(' ', "\n")
    @network[:nodes] << node
  end

  def generate_edge(source, source_type, relation, target)
    edge = {}
    target_type = if target.kind_of?(Organization) 
                    'o'
                  elsif target.kind_of?(Person)
                    'p'
                  elsif target.kind_of?(Litigation)
                    'l'
                  end
    edge[:weight] = relation.weight
    logger.debug "lofa_10"
    if target_type == source_type && target_type == 'o'
    logger.debug "lofa_12"
      edge[:id] = "o2o#{relation.id}"
    logger.debug "lofa_13"
      edge[:alternateId] = "o2o#{relation.interorg_relation.id}"
    logger.debug "lofa_14"
      edge[:label] = relation.o2o_relation_type.name
    elsif target_type == source_type && target_type == 'p'
    logger.debug "lofa_15"
      edge[:id] = "p2p#{relation.id}"
    logger.debug "lofa_17"
      edge[:alternateId] = "p2p#{relation.interpersonal_relation.id}"
    logger.debug "lofa_18"
      edge[:label] = relation.p2p_relation_type.name
    elsif target_type == 'p' && source_type == 'o'
      edge[:id] = "p2o#{relation.id}"
    logger.debug "lofa_19"
      edge[:alternateId] = "o2p#{relation.id}"
    logger.debug "lofa_10"
      edge[:label] = relation.p2o_relation_type.name
    logger.debug "lofa_21"
    elsif target_type == 'o' && source_type == 'p'
    logger.debug "lofa_22"
      edge[:id] = "o2p#{relation.id}"
    logger.debug "lofa_23"
      edge[:alternateId] = "p2o#{relation.id}"
    logger.debug "lofa_24"
      puts relation.o2p_relation_type.inspect
    logger.debug "lofa_25"
      edge[:label] = relation.o2p_relation_type.name
    logger.debug "lofa_26"
    elsif target_type == 'o' && source_type == 'l'
    logger.debug "lofa_27"
      edge[:id] = "o2l#{relation.id}"
    logger.debug "lofa_20"
      edge[:label] = relation.try.o2p_relation_type._?.name || relation.o2o_relation_type.name
    logger.debug "lofa_29"
    elsif target_type == 'l' && source_type == 'o'
    logger.debug "lofa_30"
      edge[:id] = "l2o#{relation.id}"
    logger.debug "lofa_31"
      edge[:label] = relation.try.p2o_relation_type._?.name || relation.o2o_relation_type.name
    logger.debug "lofa_32"
    elsif target_type == 'p' && source_type == 'l'
    logger.debug "lofa_33"
      edge[:id] = "p2l#{relation.id}"
    logger.debug "lofa_34"
      puts relation.inspect
    logger.debug "lofa_35"
      edge[:label] = relation.try.p2o_relation_type._?.name || relation.p2p_relation_type.name
    logger.debug "lofa_36"
    elsif target_type == 'l' && source_type == 'p'
    logger.debug "lofa_37"
      edge[:id] = "l2p#{relation.id}"
    logger.debug "lofa_38"
      edge[:label] = relation.try.o2p_relation_type._?.name || relation.p2p_relation_type.name
    logger.debug "lofa_39"
    end
    logger.debug "lofa_40"
    edge[:sourceId] = "#{source_type}#{source.id}"
    logger.debug "lofa_41"
    edge[:targetId] = "#{target_type}#{target.id}"
    logger.debug "lofa_42"
    @network[:edges] << edge
    logger.debug "lofa_43"
  end

  def generate_litigation_relations_for_litigations
    # @litigation_relations változóban lévő per kapcsolatokhoz megkeressük a pereket és végigmegyünk rajtuk 
    Litigation.find(LitigationRelation.for_relations(@litigation_relations).*.litigation_id).each do |litigation|
      # perenként megnézzük milyen node-ok tartoznak hozzá és milyen per-relation-párok vannak
      generate_litigation_relations_for_litigation(litigation)
    end
  end
  

  def generate_litigation_relations_for_litigation(litigation)
    nodes_in_litigation = {:relation_pair => [], :nodes => []}
    # végig megyünk a perhez tartozó kapcsolatokon
    litigation.litigation_relations.*.litigable.each do |litigable|
      # attól függően hogy a kapcsolat interpersonal, interorg vagy person_to_org 
      # elmentjük a kapcsolatban résztvevőket és a kapcsolatot
      if litigable.respond_to?(:person) && 
         litigable.respond_to?(:related_person) && 
         litigable.person.present? && 
         litigable.related_person.present?
        nodes_in_litigation[:relation_pair] << {litigable => [litigable.person, litigable.related_person]}
        nodes_in_litigation[:nodes] << [litigable.person, litigable.related_person] 
      elsif litigable.respond_to?(:organization) && 
            litigable.respond_to?(:related_organization) && 
            litigable.organization.present? && 
            litigable.related_organization.present?
        nodes_in_litigation[:relation_pair] << {litigable => [litigable.organization, litigable.related_organization]}
        nodes_in_litigation[:nodes] << [litigable.organization, litigable.related_organization]
      elsif litigable.respond_to?(:organization) && 
            litigable.respond_to?(:person) && 
            litigable.organization.present? && 
            litigable.person.present?
        nodes_in_litigation[:relation_pair] << {litigable => [litigable.organization, litigable.person]}
        nodes_in_litigation[:nodes] << [litigable.organization, litigable.person]
      end
      nodes_in_litigation[:nodes] = nodes_in_litigation[:nodes].flatten.uniq
      nodes_in_litigation[:relation_pair].flatten!
      # kigeneráljuk a peres kapcsolatot (vmint a perben résztvevő egyéb node-okat)
      # ha az aktuálisan vizsgált node a) résztvevője a pernek b) ő maga egy per
      if nodes_in_litigation[:nodes].include?(@explored_node) || @explored_node.kind_of?(Litigation)
        # kigeneráljuk a pert ha még nem látszik
        unless @litigations.include? litigation
          generate_node(litigation, 'l') 
          @litigations << litigation
        end
        # végig megyünk a perhez tartozó kapcsolat párokon
        nodes_in_litigation[:relation_pair].each do |relation_pair|
          # végig megyünk az adott kapcsolat párhoz tartozó node-okon
          relation_pair.values.flatten.each do |node|
            node_type = node.kind_of?(Person) ? 'p' : 'o'
            # ha még nem látszik az oldalon akkor kigeneráljuk a node-ot
            unless @non_litigation_nodes.include? node
              generate_node(node, node_type) 
              @non_litigation_nodes << node
            end
            # kigeneráljuk a kapcsolatát a perhez
            generate_edge(node, node_type, relation_pair.keys.first, litigation)
          end
        end
      # egyébként megnézzük hogy a perhez tartozó node-ok közül hány látható az oldalon,
      # ez a látható nem litigation node-ok (azaz person és org) és a perben résztvevő node-ok metszete
      # ha ez nagyobb mint egy akkor kigeneráljuk a peres kapcsolatot
      elsif (@non_litigation_nodes & nodes_in_litigation[:nodes]).length > 1
        # ha több mint egy látszik akkor kigenerájuk az aktuálisan vizsgált pert ha még nem látszik az oldalon
        unless @litigations.include? litigation
          generate_node(litigation, 'l') 
          @litigations << litigation
        end
        # végig megyünk a perhez tartozó kapcsolat párokon
        nodes_in_litigation[:relation_pair].each do |relation_pair|
          # végig megyünk az adott kapcsolat párhoz tartozó node-okon
          relation_pair.values.flatten.each do |node|
            # ha látszik az oldalon akkor kigeneráljuk a kapcsolatát a perhez
            if @non_litigation_nodes.include? node
              node_type = node.kind_of?(Person) ? 'p' : 'o'
              generate_edge(node, node_type, relation_pair.keys.first, litigation)
            end
          end
        end
      end
    end
  end

  def generate_node_edges_for_visible_non_litigation_nodes
    # az éppen kiválasztott node-on kívül az összes kliens oldalon betöltött 
    # vmint az új node-okon végigmegyünk és kigeneráljuk a kapcsolataikat
    @non_litigation_nodes.each do |node|
      if !(node.kind_of?(Person) && params[:type] == 'p' && node.id == @id ||
         node.kind_of?(Organization) && params[:type] == 'o' && node.id == @id)
        generate_node_edges_for_node(node)
      end
    end
  end

  def generate_node_edges_for_node(node)
    if node.kind_of?(Person)
      # adott személy személyes kapcsolatai
      node.personal_non_litigation_relations.each do |personal_relation|
        # csak akkor generáljuk ki a kapcsolatot ha a célszemély is látható az oldalon
        if @non_litigation_nodes.include? personal_relation.related_person
          generate_edge(personal_relation.related_person, 'p', personal_relation, node)
        end
      end
      node.person_to_org_non_litigation_relations.each do |org_relation|
        if @non_litigation_nodes.include? org_relation.organization
          generate_edge(org_relation.organization, 'o', org_relation, node)
        end
      end
    elsif node.kind_of?(Organization)
      Rails.logger.info node.inspect
      node.person_to_org_non_litigation_relations.each do |personal_relation|
        if @non_litigation_nodes.include? personal_relation.person
          generate_edge(personal_relation.person, 'p', personal_relation, node)
        end
      end
      node.interorg_non_litigation_relations.each do |org_relation|
        if @non_litigation_nodes.include? org_relation.related_organization
          generate_edge(org_relation.related_organization, 'o', org_relation, node)
        end
      end
    end
  end

  def generate_network
    # ha person kapcsolatait fedik fel
    if params[:type]=='p'
      resource = Person.find(params[:id])
      @explored_node = resource
      @persons << resource unless @persons.include? resource
      
      # személyes kapcsolatok
      resource.personal_non_litigation_relations.each do |personal_relation|
        logger.debug "================="
        logger.debug personal_relation.related_person.name
        # ha még nem látható az oldalon akkor kigeneráljuk a személyt
        unless @persons.include? personal_relation.related_person
          logger.debug "lofa1"
          @persons << personal_relation.related_person
          logger.debug "lofa2"
          generate_node(personal_relation.related_person, 'p')
          logger.debug "lofa3"
          generate_edge(personal_relation.related_person, 'p', personal_relation, resource)
          logger.debug "lofa4"
        end
          logger.debug "lofa5"
      end
      
      # intézményes kapcsolatok  
      resource.person_to_org_non_litigation_relations.each do |org_relation|
        # ha még nem látható az oldalon akkor kigeneráljuk az intézményt
        unless @organizations.include? org_relation.organization
          @organizations << org_relation.organization
          generate_node(org_relation.organization, 'o')
          generate_edge(org_relation.organization, 'o', org_relation, resource)
        end
      end
      
      # személyes peres kapcsolatok
      @litigation_relations << resource.personal_litigation_relations
      # intézményes peres kapcsolatok
      @litigation_relations << resource.person_to_org_litigation_relations

      @litigation_relations.flatten! 
      @non_litigation_nodes = @persons + @organizations

      # litigation kapcsolatok kigenerálása
      generate_litigation_relations_for_litigations
    # ha organization kapcsolatait fedik fel
    elsif params[:type] == 'o'
      resource = Organization.find(params[:id])
      @explored_node = resource
      @organizations << resource unless @organizations.include? resource

      # személyes kapcsolatok
      resource.person_to_org_non_litigation_relations.each do |personal_relation|
        @persons << personal_relation.person
        generate_node(personal_relation.person, 'p')
        generate_edge(personal_relation.person, 'p', personal_relation, resource)
      end

      # intézményes kapcsolatok  
      resource.interorg_non_litigation_relations.each do |org_relation|
        @organizations << org_relation.related_organization
        generate_node(org_relation.related_organization, 'o')
        generate_edge(org_relation.related_organization, 'o', org_relation, resource)
      end

      # személyes peres kapcsolatok
      @litigation_relations << resource.person_to_org_litigation_relations
      # intézményes peres kapcsolatok
      @litigation_relations << resource.interorg_litigation_relations

      @litigation_relations.flatten! 
      @non_litigation_nodes = @persons + @organizations

      # litigation kapcsolatok kigenerálása
      generate_litigation_relations_for_litigations
    # ha litigation kapcsolatait fedik fel
    elsif params[:type] == 'l'
      resource = Litigation.find(params[:id])
      @explored_node = resource
      @litigations << resource
      @non_litigation_nodes = @persons + @organizations
      generate_litigation_relations_for_litigation(resource)
    end
    # person és organization node-ok közötti kapcsolatok kigenerálása
    generate_node_edges_for_visible_non_litigation_nodes
    generate_node(resource, params[:type])
  end

  def index
    if params[:id] && params[:type]
      @id = params[:id].to_i
      @network = {:nodes=>[], :edges=>[]}
      @litigation_relations = []
      @persons = []
      @organizations = []
      @litigations = []
      # ajax request
      # ilyenkor figyeljük hogy milyen node-ok vannak már az oldalon, és az új kigenerálandó node-ok között milyen kapcsolatok vannak
      if request.xhr?
        person_ids = []
        organization_ids = []
        litigation_ids = []
        if params[:nodes]
          params[:nodes][0..-2].split(',').each do |node|
            match = node.match /(.*?)(\d+)$/
            person_ids << match[2] if match[1] == 'p'
            organization_ids << match[2] if match[1] == 'o'
            litigation_ids << match[2] if match[1] == 'l'
          end
          @persons = Array(Person.find_by_id(person_ids)).flatten
          @organizations = Array(Organization.find_by_id(organization_ids)).flatten
          @litigations = Array(Litigation.find_by_id(litigation_ids)).flatten
        end
        generate_network
        render :json => @network
      # ha egy másik oldalról érkezve egy konkrét adott node kapcsolatait akarják felfeldni
      else
        generate_network
      end
    end
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
end
