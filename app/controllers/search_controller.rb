class SearchController < ApplicationController

  hobo_controller

  def generate_json_node(source, source_type)
    node = {}
    node[:id] = "#{source_type}#{source.id}"
    node[:shape] = source_type == 'p' ? 'CIRCLE' : 'RECTANGLE'
    node[:label] = source.name
    @network[:nodes] << node
  end

  def generate_json_edge(source, source_type, relation, target)
    edge = {}
    target_type = target.kind_of?(Organization) ? 'o' : 'p'
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

  def generate_node_edges_for_node(node, visible_nodes)
    if node.kind_of?(Person)
      node.personal_relations.each do |personal_relation|
        if visible_nodes.include? personal_relation.related_person
          generate_json_edge(personal_relation.related_person, 'p', personal_relation, node)
        end
      end
      node.person_to_org_relations.each do |org_relation|
        if visible_nodes.include? org_relation.organization
          generate_json_edge(org_relation.organization, 'o', org_relation, node)
        end
      end
    else
      node.person_to_org_relations.each do |personal_relation|
        if visible_nodes.include? personal_relation.person
          generate_json_edge(personal_relation.person, 'p', personal_relation, node)
        end
      end
      node.interorg_relations.each do |org_relation|
        if visible_nodes.include? org_relation.related_organization
          generate_json_edge(org_relation.related_organization, 'o', org_relation, node)
        end
      end
    end
  end

  def generate_nodes(persons = [], organizations = [])
    # ha personra kerestek
    if params[:type]=='p'
      resource = Person.find(params[:id])
      resource.personal_relations.each do |personal_relation|
        persons << personal_relation.related_person
        generate_json_node(personal_relation.related_person, 'p')
        generate_json_edge(personal_relation.related_person, 'p', personal_relation, resource)
      end
      resource.person_to_org_relations.each do |org_relation|
        organizations << org_relation.organization
        generate_json_node(org_relation.organization, 'o')
        generate_json_edge(org_relation.organization, 'o', org_relation, resource)
      end
      generate_node_edges_for_visible_nodes((persons.flatten + organizations.flatten).uniq)
      generate_json_node(resource, 'p')
    # ha organization-re kerestek
    elsif params[:type] == 'o'
      resource = Organization.find(params[:id])
      resource.person_to_org_relations.each do |personal_relation|
        persons << personal_relation.person
        generate_json_node(personal_relation.person, 'p')
        generate_json_edge(personal_relation.person, 'p', personal_relation, resource)
      end
      resource.interorg_relations.each do |org_relation|
        organizations << org_relation.related_organization
        generate_json_node(org_relation.related_organization, 'o')
        generate_json_edge(org_relation.related_organization, 'o', org_relation, resource)
      end
      generate_node_edges_for_visible_nodes((persons.flatten + organizations.flatten).uniq)
      generate_json_node(resource, 'o')
    end
  end

  def index
    if params[:id] && params[:type]
      @id = params[:id].to_i
      @network = {:nodes=>[], :edges=>[]}
      if request.xhr?
        person_ids = []
        organization_ids = []
        if params[:nodes]
          # az éppen kiválasztott node-on kívül az összes kliens oldalon betöltött node-on
          # végigmegyünk és kigeneráljuk a kapcsolataikat
          params[:nodes][0..-2].split(',').each do |node|
            match = node.match /(.*?)(\d+)$/
            person_ids << match[2] if match[1] == 'p'
            organization_ids << match[2] if match[1] == 'o'
          end
          persons = Array(Person.find_by_id(person_ids) )
          organizations = Array(Organization.find_by_id(organization_ids))
        else
          persons = []
          organizations = []
        end
        generate_nodes(persons, organizations)
        render :json => @network
      else
        generate_nodes
      end
    end
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
end
