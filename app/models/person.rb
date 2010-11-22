class Person < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    first_name   :string, :required
    last_name    :string, :required
    born_at      :date
    mothers_name :string
    timestamps
  end

  def name
    last_name + ', ' + first_name + (born_at ? ', ' + born_at.to_s : '')
  end

  before_save do |r|
    if r.born_at and r.born_at.year == Time.now.year
      r.born_at = nil
    end
  end

  # ez az összes kapcsolat, azok is, amit a rendszer generált
  has_many :interpersonal_relations, :accessible => true

  # ezek csak a kézzel bevitt kapcsolatok
  has_many :personal_relations, :conditions => [ "internal = ?", false], :class_name => "InterpersonalRelation", :accessible => true

  has_many :person_to_org_relations, :accessible => true

  has_many :organizations, :through => :person_to_org_relations

  belongs_to :information_source
  belongs_to :user, :creator => true

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || (acting_user.editor? && user.id == acting_user.id)
  end

  def update_permitted?
    acting_user.administrator? || (acting_user.editor? && !user_id_changed?)
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
