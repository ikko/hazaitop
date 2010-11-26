class Financial < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    year                :integer
    balance_sheet_total :integer
    turnover            :integer
    timestamps
  end

  belongs_to :organization

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def update_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def view_permitted?(field)
    true
  end

end
