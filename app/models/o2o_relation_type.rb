class O2oRelationType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string
    weight :string
    timestamps
  end

  belongs_to :pair, :class_name => "O2oRelationType"

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
