class Organization < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name                :string, :unique
    klink               :string
    street              :string
    city                :string
    zip_code            :string
    phone               :string
    fax                 :string
    email_address       :email_address
    internet_address    :string
    trade_register_nr   :string
    tax_nr              :string
    founded_at          :date
    number_of_employees :integer
    interorg_relations_count :integer
    person_to_org_relations_count :integer
    timestamps
  end

  has_many :buyer_activity_rels
  has_many :buyer_activities, :through => :buyer_activity_rels

  has_many :buyer_type_rels
  has_many :buyer_types, :through => :buyer_type_rels

  default_scope  :order => 'name'

  validates_presence_of :information_source

  belongs_to :sector

  has_many :activity_assocs
  has_many :activities, :through => :activity_assocs, :accessible => true

#   has_many :organization_grade_assocs
#   has_many :org_grades, :through => :organization_grade_assocs, :accessible => true

  belongs_to :org_grade

  has_many :financials, :accessible => true
  has_one :recent_financial_year, :class_name => 'Financial', :order => 'year DESC'

  has_many :interorg_relations, :accessible => true
  has_many :person_to_org_relations, :accessible => true

  # helperek a vizualicáziós részhez
  has_many :person_to_org_non_litigation_relations, :conditions => [ "visual = ?", true], :class_name => "PersonToOrgRelation"
  has_many :person_to_org_litigation_relations, :conditions => [ "visual = ?", false], :class_name => "PersonToOrgRelation"
  has_many :interorg_non_litigation_relations, :conditions => [ "visual = ?", true], :class_name => "InterorgRelation"
  has_many :interorg_litigation_relations, :conditions => [ "visual = ?", false], :class_name => "InterorgRelation"

  has_many :persons,       :through => :person_to_org_relations
  # has_many :organizations, :through => :person_to_org_relations, :accessible => true
  # has_many :organizations, :through => :interorg_relations, :accessible => true, :source => :organization
  # has_many :related_organizations, :through => :interorg_relations, :accessible => true, :source => :related_organization

  belongs_to :information_source
  belongs_to :user, :creator => true

  validates_presence_of :name
  validates_presence_of :org_grade
  validates_presence_of :information_source
  validates_numericality_of :number_of_employees, :if => lambda { |r| r.number_of_employees }

  named_scope :list, :limit => 15, :order => "interorg_relations_count DESC" 
  named_scope :listed, :order => "person_to_org_relations_count DESC" #, :conditions => "interorg_relations_count > 0 or person_to_org_relations_count > 0" 
  has_many :org_histories
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
