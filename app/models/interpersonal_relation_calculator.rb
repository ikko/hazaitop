# -*- encoding : utf-8 -*-
class InterpersonalRelationCalculator < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    weight :float, :default => 1
    timestamps
  end

  belongs_to :p2p_relation_type
  belongs_to :p2o_relation_type
  belongs_to :related_p2o_relation_type, :class_name => "P2oRelationType", :index => "matrix"

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

