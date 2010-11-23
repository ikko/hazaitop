class InterpersonalRelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
    mirrored     :boolean, :default => false
    internal     :boolean, :default => false
    weight       :float
  end

  belongs_to :p2p_relation_type
  belongs_to :person
  belongs_to :related_person, :class_name => "Person"

  belongs_to :person_to_org_relation   # ha a rendszer hozta automatikusan létre a kapcsolatot, azt ez alapján tette
  belongs_to :other_person_to_org_relation, :class_name => "PersonToOrgRelation" # ez meg a másik fele az előbbinek

  belongs_to :organization             # ez csak automatikusnál értelmezendő, cacheljük

  belongs_to :information_source
  belongs_to :interpersonal_relation   # megmutatja, hgoy kinek a mirrorja. ha nil, akkor ot mirrorozzuk

  validates_presence_of :related_person
  validates_presence_of :information_source
  validates_presence_of :p2p_relation_type

  before_save do |r|
    r.weight = r.information_source.weight * r.p2p_relation_type.weight
  end

  after_create do |r|
    unless r.mirrored
      if r.p2p_relation_type.pair
        relation_type_id = r.p2p_relation_type.pair.id
      else
        relation_type_id = r.p2p_relation_type_id
      end
      InterpersonalRelation.create!(:interpersonal_relation_id => r.id,
                              :person_id => r.related_person_id,
                              :related_person_id => r.person_id,
                              :interpersonal_relation_id => r.id,
                              :p2p_relation_type_id => relation_type_id,
                              :information_source_id => r.information_source_id,
                              :organization_id => r.organization_id,
                              :person_to_org_relation_id => r.person_to_org_relation_id,
                              :other_person_to_org_relation_id => r.other_person_to_org_relation_id,
                              :mirrored => true)
      r.update_attribute :mirrored, true
    end
  end

  after_save do |r|
    o = InterpersonalRelation.find_by_id(r.interpersonal_relation_id)
    o = InterpersonalRelation.find_by_interpersonal_relation_id(r.id) unless o
    if o
      if o.related_person_id != r.person_id
        o.update_attribute :related_person_id, r.person_id
      end
      if o.p2p_relation_type_id != r.p2p_relation_type_id
        if o.p2p_relation_type and o.p2p_relation_type.pair
          if o.p2p_relation_type.pair_id != r.p2p_relation_type_id
            o.update_attribute :p2p_relation_type_id, r.p2p_relation_type.pair.id
          end
        else
          o.update_attribute :p2p_relation_type_id, r.p2p_relation_type_id
        end
      end
      if o.information_source_id != r.information_source_id
        o.update_attribute :information_source_id, r.information_source_id
      end
    end
  end

  after_save do |r|
    if r.information_source.internal and !(r.person_to_org_relation and r.other_person_to_org_relation)
      if r.interpersonal_relation
        r.interpersonal_relation.destroy
      else
        InterpersonalRelation.find_by_interpersonal_relation_id(r.id)._?.destroy
      end
      r.related_person_id = nil
    end
    if !r.related_person_id
      r.destroy
    end
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def update_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def view_permitted?(field)
    true
  end

end
