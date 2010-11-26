class Organization < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name              :string, :unique
    street            :string
    city              :string
    zip_code          :string
    trade_register_nr :string
    tax_nr            :string
    founded_at        :date
    timestamps
  end

  belongs_to :sector

  has_many :activity_assocs
  has_many :activities, :through => :activity_assocs, :accessible => true

#   has_many :organization_grade_assocs
#   has_many :org_grades, :through => :organization_grade_assocs, :accessible => true

  belongs_to :org_grade

  has_many :financials, :accessible => true

  has_many :interorg_relations, :accessible => true
  has_many :person_to_org_relations, :accessible => true

  has_many :persons,       :through => :person_to_org_relations
  # has_many :organizations, :through => :person_to_org_relations, :accessible => true
  # has_many :organizations, :through => :interorg_relations, :accessible => true, :source => :organization
  # has_many :related_organizations, :through => :interorg_relations, :accessible => true, :source => :related_organization

  belongs_to :information_source
  belongs_to :user, :creator => true

  validates_presence_of :name
  validates_presence_of :org_grade
  validates_presence_of :information_source

  named_scope :list, :limit => 15, :order => "updated_at DESC"

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
