class InterpersonalRelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
    mirrored     :boolean, :default => false
    mirror       :boolean, :default => false 
    start_time   :date
    end_time     :date
    no_end_time  :boolean, :default => false
    internal     :boolean, :default => false
    weight       :float
    visual       :boolean, :default => true
    erased_at :date  # ha a bejegyzés törlés volt a cégbíróságon, akkkor ide a törlés dátuma kerül
  end

  has_many :article_relations, :as => :relationable, :accessible => true
  has_many :articles, :through => :article_relations, :accessible => true

  default_scope :order => "related_person_id"

  belongs_to :p2p_relation_type
  belongs_to :person, :counter_cache => true

  belongs_to :related_person, :class_name => "Person"

  belongs_to :person_to_org_relation   # ha a rendszer hozta automatikusan létre a kapcsolatot, azt ez alapján tette
  belongs_to :other_person_to_org_relation, :class_name => "PersonToOrgRelation" # ez meg a másik fele az előbbinek

  belongs_to :organization             # ez csak automatikusnál értelmezendő, cacheljük

  belongs_to :information_source
  belongs_to :interpersonal_relation   # megmutatja, hgoy kinek a mirrorja. ha nil, akkor ot mirrorozzuk

  has_many :litigation_relations, :as => :litigable, :dependent => :destroy
  has_many :litigations, :through => :litigation_relations, :accessible => true

  validates_presence_of :related_person
  validates_presence_of :p2p_relation_type
  validate :litigation_related
  validate :source_present

  attr_accessor :skip_source_validation, :info_id

  def source_present 
    if information_source.blank? and article_relations.empty? and !skip_source_validation
      errors.add("Information source", "must present.")
    end
  end

  def litigation_related
    logger.info "========================================================== iii =="
    unless litigations.blank?
      errors.add("Litigation allowed only if", "relation type has legal aspect.") unless p2p_relation_type.litig
    end
  end

  before_save do |r|
    logger.info "========================================================== ii =="
    r.information_source_id = (r.info_id ? r.info_id : r.articles.first.try.information_source_id ) if r.information_source.blank?
    r.information_source_id = InformationSource.find_by_domain_name('ahalo.hu').id if r.information_source.blank?
    # r.weight = r.information_source.weight * r.p2p_relation_type.weight
  end

  after_create do |r|
    unless r.mirrored
      if r.p2p_relation_type.pair
        relation_type_id = r.p2p_relation_type.pair.id
      else
        relation_type_id = r.p2p_relation_type_id
      end
      visual = r.p2p_relation_type.visual
      interpersonal = InterpersonalRelation.new(:interpersonal_relation_id => r.id,
                                                :person_id => r.related_person_id,
                                                :related_person_id => r.person_id,
                                                :p2p_relation_type_id => relation_type_id,
                                                :information_source_id => r.information_source_id,
                                                :organization_id => r.organization_id,
                                                :person_to_org_relation_id => r.person_to_org_relation_id,
                                                :other_person_to_org_relation_id => r.other_person_to_org_relation_id,
                                                :start_time => r.start_time,
                                                :end_time => r.end_time,
                                                :no_end_time => r.no_end_time,
                                                :visual => visual,
                                                :mirrored => true,
                                                :mirror => true,
                                                :internal => r.internal
                                               )
      interpersonal.articles = r.articles
      interpersonal.litigations = r.litigations
      interpersonal.save
      r.update_attributes :mirrored => true, :interpersonal_relation_id => interpersonal.id, :visual => visual
    end
  end

  after_save do |r|
    logger.info "========================================================== i =="
    o = InterpersonalRelation.find_by_id(r.interpersonal_relation_id)
    if o
    logger.info "========================================================== A =="
      if o.related_person_id != r.person_id
        o.update_attribute :related_person_id, r.person_id
      end
      if o.p2p_relation_type_id != r.p2p_relation_type_id
    logger.info "========================================================== B =="
        if o.p2p_relation_type and o.p2p_relation_type.pair
          if o.p2p_relation_type.pair_id != r.p2p_relation_type_id
            o.update_attributes :p2p_relation_type_id => r.p2p_relation_type.pair.id, :visual => r.p2p_relation_type.visual
          end
        else
          o.update_attribute :p2p_relation_type_id, r.p2p_relation_type_id
    logger.info "========================================================== C =="
        end
      end
      if o.information_source_id != r.information_source_id
        o.update_attribute :information_source_id, r.information_source_id
    logger.info "========================================================== D =="
      end
      if o.litigations != r.litigations
    logger.info "========================================================== E =="
        o.litigations = r.litigations
    logger.info "========================================================== F =="
      end
    end
  end

  after_save do |r|
    logger.info "========================================================== ??? =="
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
