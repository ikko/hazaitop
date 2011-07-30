class Contract < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    number :string
    name :string
    description :text
    subject_and_qty :text
    sum_value  :integer
    s_vat_incl :boolean
    contracted_value :integer
    c_vat_incl :boolean
    estimated_value :integer
    e_vat_incl :boolean
    currency :string
    no_of_other_proposals :integer
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
