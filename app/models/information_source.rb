class InformationSource < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name     :string
    web      :string
    weight   :float
    internal :boolean, :default => false
    timestamps
  end


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
