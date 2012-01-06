# -*- encoding : utf-8 -*-
class O2oRelationType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string, :required
    weight :float, :default => 1
    visual :boolean, :default => true
    litig  :boolean, :default => false
    parsed   :boolean, :default => false
    role   :string
    label  :string
    timestamps
  end

  def graph_label
    label.blank? ? name : label
  end

  belongs_to :pair, :class_name => "O2oRelationType"

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

