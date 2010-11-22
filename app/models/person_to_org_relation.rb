class PersonToOrgRelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    start_time :date
    end_time   :date
    timestamps
  end

  belongs_to :p2o_relation_type
  belongs_to :organization
  belongs_to :person

  has_many :interpersonal_relations, :dependent => :destroy
  has_many :other_interpersonal_relations, :class_name => "InterpersonalRelation", :dependent => :destroy

  belongs_to :information_source

  validates_presence_of :information_source
  validates_presence_of :p2o_relation_type

  after_save do |r|
    r.match
  end

  def match
    self.interpersonal_relations.try.delete_all
    self.other_interpersonal_relations.try.delete_all
    if person # ha nem törlés történt
      if !(InterpersonalRelation.find_by_person_to_org_relation_id(id) or InterpersonalRelation.find_by_other_person_to_org_relation_id(id))
       # meg kell vizsgálnunk hogy van-e már, különben kétszer megy bele (a hobo?) az after_save-be TODO
        potential_relations = PersonToOrgRelation.find( :all, :conditions => [
          "organization_id = ? and ((start_time <= ? and end_time >= ?) or (start_time <= ? and end_time >= ?)) and id != ?", organization_id, start_time, start_time, end_time, end_time, id ])
        if potential_relations
          potential_relations.each do |pot|
            weight = (information_source.weight + pot.information_source.weight) / 2.0
            # nézzük meg, hogy a kalkulátorban rögzítve van-e a két kapcsolattipus (irányított!)
            relation_type_id = InterpersonalRelationCalculator.find_by_p2o_relation_type_id(pot.p2o_relation_type_id)._?.p2p_relation_type_id
            if !relation_type_id
              # ha megegyezik a két kapcsolat, akkor default-oljunk, a p2p kapcsolattipusukra
              if p2o_relation_type_id == pot.p2o_relation_type_id
                relation_type_id = p2o_relation_type.p2p_relation_type_id
              else
                # ha nincs info, akkor csak azt rögzítjük, hogy közös intézménynél szerepelnek
                relation_type_id = P2pRelationType.find_or_create_by_internal(true, {
                                    :name => "közös intézményi kapcsolat", :weight => 5, :internal => true }).id
              end
            end
            info = InformationSource.find :first, :conditions => { :internal => true, :weight => weight }
            info = InformationSource.create!( :internal => true, :weight => weight, :name => "system" ) if !info
            InterpersonalRelation.create!(  :p2p_relation_type_id => relation_type_id,
                                            :person_id => person_id,
                                            :related_person_id => pot.person_id,
                                            :information_source_id => info.id,
                                            :person_to_org_relation_id => id,
                                            :other_person_to_org_relation_id => pot.id,
                                            :organization_id => organization_id )
          end
        end
      end
    else # törlés történt
      self.destroy
    end
    if !organization # ha org-ból törölték
      self.destroy
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
