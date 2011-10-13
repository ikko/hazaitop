class Financial < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    year                :integer
    balance_sheet_total :integer, :limit => 8
    turnover            :integer, :limit => 8 
    timestamps
  end

  belongs_to :organization, :counter_cache => true

  validates_numericality_of :year
  validates_numericality_of :balance_sheet_total
  validates_numericality_of :turnover

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
