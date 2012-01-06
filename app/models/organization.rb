# -*- encoding : utf-8 -*-
class Organization < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name                          :string, :unique
    alternate_name                :string # ha unique miatt nem menti le, akkor itt található, h mit nem engedett
    klink                         :string
    street                        :string
    city                          :string
    country                       :string
    zip_code                      :string
    phone                         :string
    fax                           :string
    email_address                 :string
    internet_address              :string
    trade_register_nr             :string
    tax_nr                        :string
    founded_at                    :date
    number_of_employees           :integer
    interorg_relations_count      :integer, :default => 0
    person_to_org_relations_count :integer, :default => 0
    financials_count              :integer, :default => 0
    complexed_at                  :date
    ksh_number                    :string
    ksh_number_from               :date
    social_security_number        :string
    social_security_number_from   :date
    stock                         :integer, :limit => 8
    ceased_at                     :date
    ceased_from                   :date # _from mezők complexből a hatályosság vagy a változás kezdetét jelölik
    kozhasznu                     :boolean
    kozhasznu_from                :date
    kiemelten_kozhasznu           :boolean
    kiemelten_kozhasznu_from      :date
    timestamps
    complex_xml :text
    search_result_count           :integer, :default => 0
    company :boolean, :default => false
  end

  belongs_to :merge_from, :class_name => "Organization"
  has_many :organizations, :accessible => true, :foreign_key => "merge_from_id"
  belongs_to :law_successor, :class_name => "Organization"   #TODO
  
  has_many :announcements
  has_many :liquidations

  def self.merge into_this, this

    into_this.buyer_activities << this.buyer_activities
    into_this.buyer_types << this.buyer_types
    into_this.activities << this.activities
    into_this.interorg_relations << this.interorg_relations
    into_this.person_to_org_relations << this.person_to_org_relations
    into_this.org_histories << this.org_histories
    into_this.save

    this.buyer_activities.delete_all
    this.buyer_types.delete_all
    this.activities.delete_all
    this.interorg_relations.delete_all
    this.person_to_org_relations.delete_all
    this.org_histories.delete_all

    this.delete

  end

  has_many :buyer_activity_rels
  has_many :buyer_activities, :through => :buyer_activity_rels

  has_many :buyer_type_rels
  has_many :buyer_types, :through => :buyer_type_rels

  default_scope  :order => 'name'

  belongs_to :sector

  has_many :activity_assocs
  has_many :activities, :through => :activity_assocs, :accessible => true

#   has_many :organization_grade_assocs
#   has_many :org_grades, :through => :organization_grade_assocs, :accessible => true

  belongs_to :org_grade

  has_many :financials, :accessible => true
  has_one :recent_financial_year, :class_name => 'Financial', :order => 'year DESC'

  has_many :interorg_relations, :accessible => true
  has_many :person_to_org_relations, :accessible => true, :order => 'person_id'

  # helperek a vizualicáziós részhez
  has_many :person_to_org_non_litigation_relations, :conditions => [ "visual = ?", true], :class_name => "PersonToOrgRelation"
  has_many :person_to_org_litigation_relations, :conditions => [ "visual = ?", false], :class_name => "PersonToOrgRelation"
  has_many :interorg_non_litigation_relations, :conditions => [ "visual = ?", true], :class_name => "InterorgRelation"
  has_many :interorg_litigation_relations, :conditions => [ "visual = ?", false], :class_name => "InterorgRelation"

  # helperek adminhoz
  has_many :manual_person_to_org_relations, :conditions => [ "parsed = ?", false ], :class_name => "PersonToOrgRelation", :accessible => true
  has_many :manual_interorg_relations,      :conditions => [ "parsed = ?", false ], :class_name => "InterorgRelation", :accessible => true

  has_many :people,       :through => :person_to_org_relations

  # has_many :organizations, :through => :person_to_org_relations, :accessible => true
  # has_many :organizations, :through => :interorg_relations, :accessible => true, :source => :organization
  # has_many :related_organizations, :through => :interorg_relations, :accessible => true, :source => :related_organization

  belongs_to :information_source
  belongs_to :user, :creator => true

  validates_presence_of :name
  validates_presence_of :information_source
  validates_numericality_of :number_of_employees, :if => lambda { |r| r.number_of_employees }

  has_many :org_histories

  def to_param
    "#{id}-#{name.to_textual_id}"
  end

  def address
    if zip_code.blank? and city.blank? and street.blank?
      " "
    else
      "#{zip_code} #{city}, #{street}" 
    end
  end

  before_validation do |r|
    r.name = r.name.try.gsub('"','').strip
  end

  before_save do |r|
    r.company = true if r.name.downcase.include?('rt')
    r.company = true if r.name.downcase.include?('kft')
    r.company = true if r.name.downcase.include?('bt')
    r.company = true if r.name.downcase.include?('llalat') # vállalat
    r.company = true if r.name.downcase.include?('rsas') # társaság
  end

  # --- Permissions --- #
  def create_permitted?
    acting_user.administrator? || (acting_user.editor? && user.id == acting_user.id)
  end

  def update_permitted?
    acting_user.administrator? || (acting_user.editor? && !user_id_changed?)
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.supervisor?
  end

  def view_permitted?(field)
    true
  end

end

