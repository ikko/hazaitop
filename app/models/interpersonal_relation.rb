class InterpersonalRelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
    mirrored     :boolean, :default => false
  end

  belongs_to :p2p_relation_type
  belongs_to :person
  belongs_to :related_person, :class_name => "Person"

  belongs_to :information_source
  belongs_to :interpersonal_relation  # megmutatja, hgoy kinek a mirrorja. ha nil, akkor ot mirrorozzuk

  validates_presence_of :related_person
  validates_presence_of :information_source
  validates_presence_of :p2p_relation_type

  after_create do |r|
    unless r.mirrored
      if r.p2p_relation_type.pair
        relation_type_id = r.p2p_relation_type.pair.id
      else
        relation_type_id = r.p2p_relation_type_id
      end
      InterperonalRelation.create!(:interpersonal_relation_id => r.id,
                              :person_id => r.related_person_id,
                              :related_person_id => r.person_id,
                              :interpersonal_relation_id => r.id,
                              :p2p_relation_type_id => relation_type_id,
                              :information_source_id => r.information_source_id,
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
    if !r.related_person_id
      r.destroy
    end
  end

  # --- Permissions --- #

  def create_permitted?
   acting_user.administrator? || acting_user.editor?
  end

  def update_permitted?
    # return true
    acting_user.administrator? || acting_user.editor?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def view_permitted?(field)
    true
  end

end
