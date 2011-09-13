class Tender < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name           :string
    project        :string
    op_name        :string
    amount         :integer, :limit => 8
    subsidy        :float
    currency       :string
    city           :string
    county         :string
    region         :string
    decided_at     :date
    decision_score :float
    unique_string  :text
    timestamps
  end

  default_scope :order => "amount DESC"

  belongs_to :user

  belongs_to :information_source
  belongs_to :applicant, :class_name => "Organization"
  belongs_to :caller,    :class_name => "Organization"

  belongs_to :interorg_relation

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || acting_user.supervisor?
  end

  def update_permitted?
    acting_user.administrator? || acting_user.supervisor?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.supervisor?
  end

  def view_permitted?(field)
    true
  end

end
