class O2pRelationType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string, :required
    weight :float, :default => 1
    visual :boolean, :default => true
    litig  :boolean, :default => false
    label  :string
    parsed   :boolean, :default => false
    timestamps
  end

  def graph_label
    label.blank? ? name : label
  end

  belongs_to :p2p_relation_type   # ha nincs definiálva a kalkulátorban, akkor erre default-olunk
  validates_presence_of :p2p_relation_type

  belongs_to :pair, :class_name => "P2oRelationType"
#  belongs_to :mirror_of, :class_name => "P2oRelationType"


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
