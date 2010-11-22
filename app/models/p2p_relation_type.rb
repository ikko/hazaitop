class P2pRelationType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string
    weight :float
    internal :boolean, :default => false
    timestamps
  end

  belongs_to :pair, :class_name => "P2pRelationType"

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
