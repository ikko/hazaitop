class Sector < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    timestamps
  end

  has_many :organizations

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
