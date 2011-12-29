class Person < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    first_name   :string #, :required
    last_name    :string, :required
    name         :string
    street       :string
    city         :string
    zip_code     :string
    country      :string
    klink        :string
    born_at      :date
    mothers_name :string
    mothers_name_alternate :string # ha megtaláltuk, de nem biztos, h ő az, akkor ide tesszük complex-ből
    complexed_at :date
    interpersonal_relations_count :integer, :default => 0
    person_to_org_relations_count :integer, :default => 0
    complex_xml :text
    timestamps
  end

  default_scope  :order => 'last_name, first_name' 

  before_save do |r|
    r.name = r.last_name.to_s + ' ' + r.first_name.to_s
    if r.born_at and r.born_at.year == Time.now.year
      r.born_at = nil
    elsif r.born_at
      r.name << r.born_at.to_s
    end
  end

  validates_presence_of :information_source

  has_many :person_grade_assocs
  has_many :person_grades, :through => :person_grade_assocs, :accessible => true

  belongs_to :place_of_birth

  # ez az összes kapcsolat, azok is, amit a rendszer generált
  has_many :interpersonal_relations, :accessible => true

  # ezek csak a kézzel bevitt kapcsolatok
  has_many :personal_relations, :conditions => [ "internal = ?", false], :class_name => "InterpersonalRelation", :accessible => true

  # helperek a vizualicáziós részhez
  has_many :personal_non_litigation_relations, :conditions => [ "visual = ?", true], :class_name => "InterpersonalRelation"
  has_many :personal_litigation_relations, :conditions => [ "visual = ?", false], :class_name => "InterpersonalRelation"
  has_many :person_to_org_non_litigation_relations, :conditions => [ "visual = ?", true], :class_name => "PersonToOrgRelation"
  has_many :person_to_org_litigation_relations, :conditions => [ "visual = ?", false], :class_name => "PersonToOrgRelation"


  # helperek adminhoz
  has_many :manual_interpersonal_relations, :conditions => [ "parsed = ?", false], :class_name => "InterpersonalRelation", :accessible => true
  has_many :manual_person_to_org_relations, :conditions => [ "parsed = ?", false], :class_name => "PersonToOrgRelation", :accessible => true

  has_many :person_to_org_relations, :accessible => true, :order => "organization_id"

  has_many :organizations, :through => :person_to_org_relations

  belongs_to :information_source
  belongs_to :user, :creator => true

  has_many :person_histories

  def to_param
    "#{id}-#{name.to_textual_id}"
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
