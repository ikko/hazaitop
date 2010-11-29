class SearchController < ApplicationController

  hobo_controller

  def generate_xgmml_node(max_weight, source, source_type, relation=false, target=false)
    # ha van relation, akkor van már max_weight is
    weight = relation ? (relation.weight / max_weight) * 10 : nil
    shape = source_type == 'p' ? 'CIRCLE' : 'RECTANGLE'
    node = "<node id='#{source_type}#{source.id}' label='#{source.name}'><graphics type='#{shape}'/></node>"
    if target
      target_type = target.kind_of?(Organization) ? 'o' : 'p'
      node << if target_type == source_type && target_type == 'o'
        "<edge id='o2o#{relation.id}' source='o#{source.id}' target='o#{target.id}' label='#{relation.o2o_relation_type.name}'><att type='real' name='weight' value='#{relation.weight}'/><graphics width='#{weight}'/></edge>"
      elsif target_type == source_type && target_type == 'p'
        "<edge id='p2p#{relation.id}' source='p#{source.id}' target='p#{target.id}' label='#{relation.p2p_relation_type.name}'><att type='real' name='weight' value='#{relation.weight}'/><graphics width='#{weight}'/></edge>"
      else
        "<edge id='p2o#{relation.id}' source='#{source_type}#{source.id}' target='#{target_type}#{target.id}' label='#{relation.p2o_relation_type.name}'><att type='real'  name='weight' value='#{relation.weight}'/><graphics width='#{weight}'/></edge>"
      end
    else
      node
    end
  end

  def generate_json_node(source, source_type, relation, target)
    resp = {}
    target_type = target.kind_of?(Organization) ? 'o' : 'p'
    resp[:id] = "#{source_type}#{source.id}"
    resp[:shape] = source_type == 'p' ? 'CIRCLE' : 'RECTANGLE'
    resp[:label] = source.name
    resp[:relationWeight] = relation.weight
    if target_type == source_type && target_type == 'o'
      resp[:relationId] = "o2o#{relation.id}"
      resp[:alternateRelationId] = "o2o#{relation.interorg_relation.id}"
      resp[:relationLabel] = relation.o2o_relation_type.name
    elsif target_type == source_type && target_type == 'p'
      resp[:relationId] = "p2p#{relation.id}"
      resp[:alternateRelationId] = "p2p#{relation.interpersonal_relation.id}"
      resp[:relationLabel] = relation.p2p_relation_type.name
    else
      resp[:relationId] = "p2o#{relation.id}"
      resp[:relationLabel] = relation.p2o_relation_type.name
    end
    resp
  end

  def organization_node(source, max_weight = nil, relation=false, target=false)
    generate_xgmml_node(max_weight, source, 'o', relation, target)
  end

  def person_node(source, max_weight = nil, relation=false, target=false)
    generate_xgmml_node(max_weight, source, 'p', relation, target)
  end

  def index
    if params[:id] && params[:type]
      xgmml = <<-XGMML
<graph label="Cytoscape Web" directed="0" Graphic="1" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:cy="http://www.cytoscape.org" xmlns="http://www.cs.rpi.edu/XGMML">
XGMML
      # ha personra kerestek
      # type 0: person, 1: organization
      if params[:type]=='0' && resource = Person.find(params[:id])
        xgmml << person_node(resource)
        personal_relations = resource.personal_relations
        organization_relations = resource.person_to_org_relations
        max_weight = [personal_relations.max_by(&:weight)._?.weight, 
                      organization_relations.max_by(&:weight)._?.weight].flatten.compact.max
        personal_relations.each do |personal_relation|
          xgmml << person_node(personal_relation.related_person, max_weight, personal_relation, resource)
        end
        organization_relations.each do |org_relation|
          xgmml << organization_node(org_relation.organization, max_weight, org_relation, resource)
        end
      # ha organizationre kerestek
      elsif params[:type]=='1' && resource = Organization.find(params[:id])
        xgmml << organization_node(resource)
        personal_relations = resource.person_to_org_relations
        organization_relations = resource.interorg_relations
        max_weight = [personal_relations.max_by(&:weight)._?.weight, 
                      organization_relations.max_by(&:weight)._?.weight].flatten.compact.max
        personal_relations.each do |personal_relation|
          xgmml << person_node(personal_relation.person, max_weight, personal_relation, resource)
        end
        organization_relations.each do |org_relation|
          xgmml << organization_node(org_relation.related_organization, max_weight, org_relation, resource)
        end
      end
      render :text => (xgmml<<'</graph>')
    # ha konkrét node szomszédait kérik le
    elsif params[:id]
      resp = {:nodes => []}
      if params[:id][0,1] == 'p'
        resource = Person.find(params[:id][1..-1])
        personal_relations = resource.personal_relations
        organization_relations = resource.person_to_org_relations
        resp[:maxWeight] = [personal_relations.max_by(&:weight)._?.weight, 
                            organization_relations.max_by(&:weight)._?.weight].flatten.compact.max
        personal_relations.each do |personal_relation|
          resp[:nodes] << generate_json_node(personal_relation.related_person, 'p', personal_relation, resource)
        end
        organization_relations.each do |org_relation|
          resp[:nodes] << generate_json_node(org_relation.organization, 'o', org_relation, resource)
        end
      else
        resource = Organization.find(params[:id][1..-1])
        personal_relations = resource.person_to_org_relations
        organization_relations = resource.interorg_relations
        resp[:maxWeight] = [personal_relations.max_by(&:weight)._?.weight, 
                            organization_relations.max_by(&:weight)._?.weight].flatten.compact.max
        personal_relations.each do |personal_relation|
          resp[:nodes] << generate_json_node(personal_relation.person, 'p', personal_relation, resource)
        end
        organization_relations.each do |org_relation|
          resp[:nodes] << generate_json_node(org_relation.organization, 'o', org_relation, resource)
        end
      end
      render :json => resp
    end
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
end
