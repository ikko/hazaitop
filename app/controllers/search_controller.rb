class SearchController < ApplicationController

  hobo_controller

  def generate_node(source, source_type, relation=false, target=false)
    shape = source_type == 'p' ? 'CIRCLE' : 'RECTANGLE'
    node = "<node id='#{source_type}#{source.id}' label='#{source.name}'><graphics type='#{shape}'/></node>"
    if target
      target_type = target.kind_of?(Organization) ? 'o' : 'p'
      node << if target_type == source_type && target_type == 'o'
        "<edge source='o#{source.id}' target='o#{target.id}' label='#{relation.o2o_relation_type.name}' weight='#{relation && relation.weight.to_i}'/>"
      elsif target_type == source_type && target_type == 'p'
        "<edge source='p#{source.id}' target='p#{target.id}' label='#{relation.p2p_relation_type.name}' weight='#{relation && relation.weight.to_i}'/>"
      else
        "<edge source='#{source_type}#{source.id}' target='#{target_type}#{target.id}' label='#{relation.p2o_relation_type.name}' weight='#{relation && relation.weight.to_i}'/>"
      end
    else
      node
    end
  end

  def organization_node(source, relation=false, target=false)
    generate_node(source, 'o', relation, target)
  end

  def person_node(source, relation=false, target=false)
    generate_node(source, 'p', relation, target)
  end

  def index
    # type 0: person, 1: organization
    if params[:id] && params[:type]
      xgmml = <<-XGMML
<graph label="Cytoscape Web" directed="0" Graphic="1" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:cy="http://www.cytoscape.org" xmlns="http://www.cs.rpi.edu/XGMML">
XGMML
      if params[:type]=='0' && resource = Person.find_by_id(params[:id])
        xgmml << person_node(resource)
        personal_relations = resource.personal_relations
        organization_relations = resource.person_to_org_relations
        personal_relations.each do |personal_relation|
          xgmml << person_node(personal_relation.related_person, personal_relation, resource)
        end
        organization_relations.each do |org_relation|
          xgmml << organization_node(org_relation.organization, org_relation, resource)
        end
      else resource = Organization.find_by_id(params[:id])
        xgmml << organization_node(resource)
        personal_relations = resource.person_to_org_relations
        organization_relations = resource.interorg_relations
        personal_relations.each do |personal_relation|
          puts personal_relation
          puts personal_relation.person
          xgmml << person_node(personal_relation.person, personal_relation, resource)
        end
        organization_relations.each do |org_relation|
          puts org_relation
          puts org_relation.related_organization
          xgmml << organization_node(org_relation.related_organization, org_relation, resource)
        end
      end
      render :text => (xgmml<<'</graph>')
    end
  end
end
