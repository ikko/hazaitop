class Contract < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    no_of_proposals :integer
    name :string
    description :text
    sum_value  :integer, :limit => 8
    original_sum_value :string
    s_vat_incl :boolean
    contracted_value :integer, :limit => 8
    c_vat_incl :boolean
    original_contracted_value :string
    estimated_value :integer, :limit => 8
    e_vat_incl :boolean
    currency :string
    subject_and_qty :text
    number :string
    issued_at :date
    case_number :string
    timestamps
  end

  default_scope  :order => 'contracted_value DESC'

  has_many :contract_type_rels
  has_many :contract_types, :through => :contract_type_rels

  has_many :contract_frame_rels
  has_many :contract_frames, :through => :contract_frame_rels

  has_many :contract_cpv_rels
  has_many :cpvs, :through => :contract_cpv_rels

  belongs_to :buyer,  :class_name => "Organization"
  belongs_to :seller, :class_name => "Organization"

  belongs_to :notification

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
