class Notification < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
    name :string
    issued_at :date
    processed :boolean, :default => false
    number :string
    contracted_value :string
  end

  has_many :contracts
  has_many :interorg_relations

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
