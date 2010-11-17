class InterorgRelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    start_time :date
    end_time   :date
    value      :integer
    timestamps
  end

  belongs_to :o2o_relation_type
  belongs_to :organization_a, :class_name => "Organization"
  belongs_to :organization_b, :class_name => "Organization"

  belongs_to :information_source
  belongs_to :user, :creator => true

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
