class LitigationsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def show
    @this = find_instance
    person_to_org_relation_ids = []
    interpersonal_relation_ids = []
    interorg_relation_ids = []
    @this.litigation_relations.each do |rel|
      if rel.litigable_type == "PersonToOrgRelation"
        person_to_org_relation_ids << rel.litigable_id
      elsif rel.litigable_type == "InterpersonalRelation"
        interpersonal_relation_ids << rel.litigable_id
      elsif rel.litigable_type == "InterorgRelation"
        interorg_relation_ids << rel.litigable_id
      end
    end
    @person_to_org_relations = PersonToOrgRelation.find   person_to_org_relation_ids
    @interpersonal_relations = InterpersonalRelation.find interpersonal_relation_ids
    @interorg_relations      = InterorgRelation.find      interorg_relation_ids
  end
end