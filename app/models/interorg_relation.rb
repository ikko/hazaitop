class InterorgRelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
    mirrored     :boolean, :default => false
  end

  belongs_to :o2o_relation_type
  belongs_to :organization
  belongs_to :related_organization, :class_name => "Organization"

  belongs_to :information_source
  belongs_to :interorg_relation  # megmutatja, hgoy kinek a mirrorja. ha nil, akkor ot mirrorozzuk

  validates_presence_of :related_organization
  validates_presence_of :information_source
  validates_presence_of :o2o_relation_type

  after_create do |r|
    unless r.mirrored
      if r.o2o_relation_type.pair
        relation_type_id = r.o2o_relation_type.pair.id
      else
        relation_type_id = r.o2o_relation_type_id
      end
      InterorgRelation.create!(:interorg_relation_id => r.id,
                              :organization_id => r.related_organization_id,
                              :related_organization_id => r.organization_id,
                              :interorg_relation_id => r.id,
                              :o2o_relation_type_id => relation_type_id,
                              :information_source_id => r.information_source_id,
                              :mirrored => true)
      r.update_attribute :mirrored, true
    end
  end

  after_save do |r|
    o = InterorgRelation.find_by_id(r.interorg_relation_id)
    o = InterorgRelation.find_by_interorg_relation_id(r.id) unless o
    if o
      if o.related_organization_id != r.organization_id
        o.update_attribute :related_organization_id, r.organization_id
      end
      if o.o2o_relation_type_id != r.o2o_relation_type_id
        if o.o2o_relation_type and o.o2o_relation_type.pair
          if o.o2o_relation_type.pair_id != r.o2o_relation_type_id
            o.update_attribute :o2o_relation_type_id, r.o2o_relation_type.pair.id
          end
        else
          o.update_attribute :o2o_relation_type_id, r.o2o_relation_type_id
        end
      end
      if o.information_source_id != r.information_source_id
        o.update_attribute :information_source_id, r.information_source_id
      end
    end
  end

  after_save do |r|
    if !r.related_organization_id
      r.destroy
    end
  end

  # --- Permissions --- #

  def create_permitted?
   acting_user.administrator? || (acting_user.editor? )# && !mirrored_changed? && !interorg_relation_id_changed?)
  end

  def update_permitted?
    # return true
    acting_user.administrator? || (acting_user.editor? )#&& !mirrored_changed? && !interorg_relation_id_changed?)
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def view_permitted?(field)
    true
  end

end
