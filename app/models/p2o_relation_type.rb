class P2oRelationType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string, :required
    weight :float, :required, :default => 1
    visual :boolean, :default => true
    litig  :boolean, :default => false
    timestamps
  end

  belongs_to :p2p_relation_type   # ha nincs definiálva a kalkulátorban, akkor erre default-olunk
  validates_presence_of :p2p_relation_type

  belongs_to :pair, :class_name => "O2pRelationType"


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
