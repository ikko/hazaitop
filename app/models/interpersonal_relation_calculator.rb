class InterpersonalRelationCalculator < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    weight :integer
    timestamps
  end

  belongs_to :p2p_relation_type
  belongs_to :p2o_relation_type
  belongs_to :related_p2o_relation_type, :class_name => "P2oRelationType"

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
