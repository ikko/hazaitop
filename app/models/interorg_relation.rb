# -*- encoding : utf-8 -*-
class InterorgRelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name         :text
    timestamps
    mirrored     :boolean, :default => false
    mirror       :boolean, :default => false
    weight       :float,   :default => 1
    visual       :boolean, :default => true
    value        :integer, :limit => 8
    start_time   :date
    end_time     :date
    no_end_time  :boolean, :default => false
    currency     :string
    vat_incl     :boolean
    issued_at    :date
    erased_at    :date  # ha a bejegyzés törlés volt a cégbíróságon, akkkor ide a törlés dátuma kerül
    note         :text
    role         :string    # tisztség complexbol
    role2        :string    # tisztség complexbol névből kiparse-olva
    jelentos  :boolean, :default => false
    tobbsegi  :boolean, :default => false
    kozvetlen :boolean, :default => false
    szavazat_50_szazalek_felett  :boolean, :default => false
    szavazat_tobbsegi_befolyas   :boolean, :default => false
    szavazat_egyeduli_reszvenyes :boolean, :default => false
    szavazat_egyeduli_reszvenyes :boolean, :default => false
    parsed :boolean, :default => false
    search_result_count :integer, :default => 0
  end

  default_scope :order => "related_organization_id"

  belongs_to :notification
  belongs_to :contract
  belongs_to :tender

  has_many :article_relations, :as => :relationable, :accessible => true
  has_many :articles, :through => :article_relations, :accessible => true

  belongs_to :o2o_relation_type
  belongs_to :organization, :counter_cache => true

  belongs_to :related_organization, :class_name => "Organization"

  belongs_to :information_source
  belongs_to :interorg_relation  # megmutatja, hgoy kinek a mirrorja. ha nil, akkor ot mirrorozzuk

  has_many :litigation_relations, :as => :litigable, :dependent => :destroy
  has_many :litigations, :through => :litigation_relations, :accessible => true

  validates_presence_of :related_organization
  validates_presence_of :o2o_relation_type
  validate :litigation_related
  validate :source_present

  has_many :interorg_relations #, :dependent => :destroy
#=begin
  after_destroy do |r| 
    r.interorg_relations.first.try.destroy 
    r.interorg_relation.try.destroy
  end
  

  def source_present
    if information_source.blank? and articles.empty?
      errors.add("Information source", "must present.")
    end
  end


  def litigation_related
    unless litigations.blank?
      errors.add("Litigation allowed only if", "relation type has legal aspect.") unless o2o_relation_type.litig
    end
  end

  before_save do |r|
    r.information_source_id = (r.info_id ? r.info_id : r.articles.first.try.information_source_id ) if r.information_source.blank?
    r.information_source_id = InformationSource.find_by_domain_name('ahalo.hu').id if r.information_source.blank?
    r.parsed = r.o2o_relation_type.parsed if r.o2o_relation_type
    # r.weight = r.information_source.weight * r.o2o_relation_type.weight
  end

  after_create do |r|
    unless r.mirrored
      if r.o2o_relation_type.pair
        relation_type_id = r.o2o_relation_type.pair.id
      else
        relation_type_id = r.o2o_relation_type_id
      end
      visual = r.o2o_relation_type.visual
      interorg = InterorgRelation.create!(:interorg_relation_id => r.id,
                                          :organization_id => r.related_organization_id,
                                          :related_organization_id => r.organization_id,
                                          :interorg_relation_id => r.id,
                                          :o2o_relation_type_id => relation_type_id,
                                          :information_source_id => r.information_source_id,
                                          :parsed => r.parsed,
                                          :visual => visual,
                                          :mirrored => true,
                                          :value => r.value,
                                          :currency => r.currency,
                                          :vat_incl => r.vat_incl,
                                          :contract_id => r.contract_id,
                                          :notification_id => r.notification_id,
                                          :tender_id => r.tender_id,
                                          :issued_at => r.issued_at,
                                          :mirror => true)
      interorg.articles = r.articles
      interorg.litigations = r.litigations
      r.update_attributes :mirrored => true, :interorg_relation_id => interorg.id, :visual => visual
    end
  end

  after_save do |r|
    o = InterorgRelation.find_by_id(r.interorg_relation_id)
    if o
      if o.related_organization_id != r.organization_id
        o.update_attribute :related_organization_id, r.organization_id
      end
      if o.o2o_relation_type_id != r.o2o_relation_type_id
        if o.o2o_relation_type and o.o2o_relation_type.pair
          if o.o2o_relation_type.pair_id != r.o2o_relation_type_id
            o.update_attributes :o2o_relation_type_id => r.o2o_relation_type.pair.id, :visual => r.o2o_relation_type.visual
          end
        else
          o.update_attribute :o2o_relation_type_id, r.o2o_relation_type_id
        end
      end
      if o.information_source_id != r.information_source_id
        o.update_attribute :information_source_id, r.information_source_id
      end
      if o.articles != r.articles
        o.articles = r.articles
      end
      if o.litigations != r.litigations
        o.litigations = r.litigations
      end
    end
  end

  after_save do |r|
    if !r.related_organization_id or !r.organization_id
      r.destroy
    end
  end

  after_destroy do |r|
    r.interorg_relation.try.destroy
  end
#=end
  def to_param
    if name.present?
      "#{id}-#{name.to_textual_id}"
    else
      id
    end
  end


  def name 
    attributes["name"].blank? ? "<dokumentáció>" : attributes["name"]
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

