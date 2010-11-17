class Person < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    first_name   :string
    last_name    :string
    born_at      :date
    mothers_name :string
    timestamps
  end

  has_many :interpersonal_relations
  has_many :person_to_org_relations

  has_many :organizations, :through => :person_to_org_relations, :accessible => true
  has_many :related_persons_a, :through => :interpersonal_relations, :accessible => true, :source => :person_a
  has_many :related_persons_b, :through => :interpersonal_relations, :accessible => true, :source => :person_b

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
