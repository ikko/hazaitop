class InterorgRelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
    mirrored     :boolean, :default => false
    mirror       :boolean, :default => false
    weight       :float
    visual       :boolean, :default => true
    value        :integer
    currency     :string
    vat_incl     :boolean
  end

  default_scope :order => "related_organization_id"

  belongs_to :notification
  belongs_to :contract

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

  def source_present
    if information_source.blank? and articles.empty?
      errors.add("Information source or article", "must present.")
    end
  end


  def litigation_related
   unless litigations.blank?
     errors.add("Litigation allowed only if", "relation type has legal aspect.") unless o2o_relation_type.litig
   end
  end

  before_save do |r|
    r.information_source_id = r.articles.first.information_source_id if r.information_source.blank?
    r.weight = r.information_source.weight * r.o2o_relation_type.weight
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
                              :visual => visual,
                              :mirrored => true,
                              :value => r.value,
                              :currency => r.currency,
                              :vat_incl => r.vat_incl,
                              :contract_id => r.contract_id,
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
      if o.litigations != r.litigations
        o.litigations = r.litigations
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
