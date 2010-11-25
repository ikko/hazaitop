class Litigation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name       :string
    description  :text
    start_time :date
    end_time   :date
    timestamps
  end

  has_many :litigation_relations

#  has_many :interorg_relations, :through => :litigation_relations
#  has_many :interpersonal_relations, :through => :litigation_relations
#  has_many :person_to_org_relations, :through => :litigation_relations

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
