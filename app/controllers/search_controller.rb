class SearchController < ApplicationController

  hobo_controller

  def generate_json_node(source, source_type)
    node = {}
    node[:id] = "#{source_type}#{source.id}"
    node[:shape] = if source_type == 'p'
                    'CIRCLE'
                   elsif source_type == 'o'
                     'RECTANGLE'
                   elsif source_type == 'l'
                     'DIAMOND'
                   end
    node[:label] = source.name
    @network[:nodes] << node
  end

  def generate_json_edge(source, source_type, relation, target)
    edge = {}
    target_type = if target.kind_of?(Organization) 
                    'o'
                  elsif target.kind_of?(Person)
                    'p'
                  elsif target.kind_of(Litigation)
                    'l'
                  end
    edge[:weight] = relation.weight
    if target_type == source_type && target_type == 'o'
      edge[:id] = "o2o#{relation.id}"
      edge[:alternateId] = "o2o#{relation.interorg_relation.id}"
      edge[:label] = relation.o2o_relation_type.name
    elsif target_type == source_type && target_type == 'p'
      edge[:id] = "p2p#{relation.id}"
      edge[:alternateId] = "p2p#{relation.interpersonal_relation.id}"
      edge[:label] = relation.p2p_relation_type.name
    elsif target_type == 'p' && source_type == 'o'
      edge[:id] = "p2o#{relation.id}"
      edge[:alternateId] = "o2p#{relation.id}"
      edge[:label] = relation.p2o_relation_type.name
    elsif target_type == 'o' && source_type == 'p'
      edge[:id] = "o2p#{relation.id}"
      edge[:alternateId] = "p2o#{relation.id}"
      edge[:label] = relation.o2p_relation_type.name
    elsif target_type == 'o' && source_type == 'l'
      edge[:id] = "o2l#{relation.id}"
      edge[:alternateId] = "l2o#{relation.id}"
      edge[:label] = relation.try.o2p_relation_type._?.name || relation.o2o_relation_type.name
    elsif target_type == 'l' && source_type == 'o'
      edge[:id] = "l2o#{relation.id}"
      edge[:alternateId] = "o2l#{relation.id}"
      edge[:label] = relation.try.p2o_relation_type._?.name || relation.o2o_relation_type.name
    elsif target_type == 'p' && source_type == 'l'
      edge[:id] = "p2l#{relation.id}"
      edge[:alternateId] = "l2p#{relation.id}"
      puts relation.inspect
      edge[:label] = relation.try.p2o_relation_type._?.name || relation.p2p_relation_type.name
    elsif target_type == 'l' && source_type == 'p'
      edge[:id] = "l2p#{relation.id}"
      edge[:alternateId] = "p2l#{relation.id}"
      edge[:label] = relation.try.o2p_relation_type._?.name || relation.p2p_relation_type.name
    end
    edge[:sourceId] = "#{source_type}#{source.id}"
    edge[:targetId] = "#{target_type}#{target.id}"
    @network[:edges] << edge
  end

  def generate_node_edges_for_visible_nodes(visible_nodes)
    # az éppen kiválasztott node-on kívül az összes kliens oldalon betöltött 
    # vmint az új node-okon végigmegyünk és kigeneráljuk a kapcsolataikat
    visible_nodes.each do |node|
      if !(node.kind_of?(Person) && node.id == @id)
        generate_node_edges_for_node(node, visible_nodes)
      end
    end
  end

  def generate_litigations(relation, target, visible_nodes)
    relation.litigations.each do |litigation|
      litigation.litigation_relations do |litigation_relation|
        if visible_nodes.include? litigation
          generate_json_edge(litigation, 'l', litigation_relation, target)
        end
      end
    end
  end

  def generate_node_edges_for_node(node, visible_nodes)
    if node.kind_of?(Person)
      node.interpersonal_relations.each do |personal_relation|
        if visible_nodes.include? personal_relation.related_person
          generate_json_edge(personal_relation.related_person, 'p', personal_relation, node)
        end
        generate_litigations(personal_relation, node, visible_nodes)
      end
      node.person_to_org_relations.each do |org_relation|
        if visible_nodes.include? org_relation.organization
          generate_json_edge(org_relation.organization, 'o', org_relation, node)
        end
        generate_litigations(org_relation, node, visible_nodes)
      end
    elsif node.kind_of?(Organization)
      node.person_to_org_relations.each do |personal_relation|
        if visible_nodes.include? personal_relation.person
          generate_json_edge(personal_relation.person, 'p', personal_relation, node)
        end
        generate_litigations(personal_relation, node, visible_nodes)
      end
      node.interorg_relations.each do |org_relation|
        if visible_nodes.include? org_relation.related_organization
          generate_json_edge(org_relation.related_organization, 'o', org_relation, node)
        end
        generate_litigations(org_relation, node, visible_nodes)
      end
    elsif node.kind_of?(Litigation)
=begin
if visible_nodes.include? litigation
        generate_json_edge(node.litigation_relations, 'l', litigation_relation, target)
      end
    end
=end
    end
  end

  def generate_network(persons = [], organizations = [], litigations = [])
    # ha person kapcsolatait fedik fel
    if params[:type]=='p'
      resource = Person.find(params[:id])
      resource.visual_personal_relations.each do |personal_relation|
        persons << personal_relation.related_person
        generate_json_node(personal_relation.related_person, 'p')
        generate_json_edge(personal_relation.related_person, 'p', personal_relation, resource)
        personal_relation.litigations.each do |litigation|
          litigations << litigation
          generate_json_node(litigation, 'l')
          generate_json_edge(litigation, 'l', personal_relation, resource)
        end
      end
      resource.visual_person_to_org_relations.each do |org_relation|
        organizations << org_relation.organization
        generate_json_node(org_relation.organization, 'o')
        generate_json_edge(org_relation.organization, 'o', org_relation, resource)
        org_relation.litigations.each do |litigation|
          litigations << litigation
          generate_json_node(litigation, 'l')
          generate_json_edge(litigation, 'l', org_relation, resource)
        end
      end
      generate_node_edges_for_visible_nodes((persons + organizations + litigations).uniq)
      generate_json_node(resource, 'p')
    # ha organization kapcsolatait fedik fel
    elsif params[:type] == 'o'
      resource = Organization.find(params[:id])
      resource.person_to_org_relations.each do |personal_relation|
        persons << personal_relation.person
        generate_json_node(personal_relation.person, 'p')
        generate_json_edge(personal_relation.person, 'p', personal_relation, resource)
        personal_relation.litigations.each do |litigation|
          litigations << litigation
          generate_json_node(litigation, 'l')
          generate_json_edge(litigation, 'l', personal_relation, resource)
        end
      end
      resource.interorg_relations.each do |org_relation|
        organizations << org_relation.related_organization
        generate_json_node(org_relation.related_organization, 'o')
        generate_json_edge(org_relation.related_organization, 'o', org_relation, resource)
        org_relation.litigations.each do |litigation|
          litigations << litigation
          generate_json_node(litigation, 'l')
          generate_json_edge(litigation, 'l', org_relation, resource)
        end
      end
      generate_node_edges_for_visible_nodes((persons + organizations + litigations).uniq)
      generate_json_node(resource, 'o')
    # ha litigation kapcsolatait fedik fel
    elsif params[:type] == 'l'
      resource = Litigation.find(params[:id])
      litigations << resource
      person_to_org_relation_ids = []
      interpersonal_relation_ids = []
      interorg_relation_ids = []
      resource.litigation_relations.each do |litigation_relation|
        if litigation_relation.litigable_type == "PersonToOrgRelation"
          person_to_org_relation_ids << litigation_relation.litigable_id
        elsif litigation_relation.litigable_type == "InterpersonalRelation"
          interpersonal_relation_ids << litigation_relation.litigable_id
        elsif litigation_relation.litigable_type == "InterorgRelation"
          interorg_relation_ids << litigation_relation.litigable_id
        end
      end
      person_to_org_relations = PersonToOrgRelation.find   person_to_org_relation_ids
      interpersonal_relations = InterpersonalRelation.find interpersonal_relation_ids
      interorg_relations      = InterorgRelation.find      interorg_relation_ids
      person_to_org_relations.each do |p2o_rel|
        persons << p2o_rel.person
        organizations << p2o_rel.organization
        generate_json_node(p2o_rel.person, 'p')
        generate_json_edge(p2o_rel.person, 'p', p2o_rel, resource)
        generate_json_node(p2o_rel.organization, 'o')
        generate_json_edge(p2o_rel.organization, 'o', p2o_rel, resource)
      end
      interpersonal_relations.each do |p2p_rel|
        persons << p2p_rel.person
        persons << p2p_rel.related_person
        generate_json_node(p2p_rel.person, 'p')
        generate_json_edge(p2p_rel.person, 'p', p2p_rel, resource)
        generate_json_node(p2p_rel.related_person, 'p')
        generate_json_edge(p2p_rel.related_person, 'p', p2p_rel, resource)
      end
      interorg_relation.each do |o2o_rel|
        organizations << o2o_rel.organization
        organizations << o2o_rel.related_organization
        generate_json_node(o2o_rel.organization, 'p')
        generate_json_edge(o2o_rel.organization, 'p', o2o_rel, resource)
        generate_json_node(o2o_rel.related_organization, 'o')
        generate_json_edge(o2o_rel.related_organization, 'o', o2o_rel, resource)
      end
      generate_node_edges_for_visible_nodes((persons + organizations + litigations).uniq)
      generate_json_node(resource, 'l')
    end
  end

  def index
    if params[:id] && params[:type]
      @id = params[:id].to_i
      @network = {:nodes=>[], :edges=>[]}
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
          persons = Array(Person.find_by_id(person_ids) )
          organizations = Array(Organization.find_by_id(organization_ids))
          litigations = Array(Litigation.find_by_id(litigation_ids))
        else
          persons = []
          organizations = []
          litigations = []
        end
        generate_network(persons.flatten, organizations.flatten, litigations.flatten)
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
