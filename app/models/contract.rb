class Contract < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    buyer :string
    description :text
    subject_and_qty :text
    seller :string
    sum_value  :integer
    contracted_value :integer
    estimated_value :integer
    currency :string
    vat_incl :boolean
    contracting_at :date
    no_of_other_proposals :integer
    timestamps
  end

  has_many :contract_type_rels
  has_many :contract_types, :through => :contract_type_rels

  has_many :contract_frame_rels
  has_many :contract_frames, :through => :contract_frame_rels

  has_many :contract_cpv_rels
  has_many :cpvs, :through => :contract_cpv_rels


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
