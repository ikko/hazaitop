# -*- encoding : utf-8 -*-
class P2oRelationType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string, :required
    weight :float, :required, :default => 1
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
# validates_presence_of :p2p_relation_type

  belongs_to :pair, :class_name => "O2pRelationType"

  has_many :relations, :through => :p2o_relations
  has_many :p2o_relations, :accessible => true


  has_many :person_to_org_relations
  has_many :organizations, :through => :person_to_org_relations, :accessible => true
  has_many :people       , :through => :person_to_org_relations, :accessible => true

  after_create do |r|
    t = O2pRelationType.create( :name => r.name,
                            :weight => r.weight,
                            :visual => r.visual,
                            :litig => r.litig,
                            :mirror_of_id => r.id,
                            :p2p_relation_type_id => r.p2p_relation_type_id
                          )
    r.update_attribute :pair_id, t.id
  end

  after_save do |r|
    o2p = O2pRelationType.find( r.pair_id )
    o2p.update_attributes( :name => r.name,
                           :weight => r.weight,
                           :visual => r.visual,
                           :litig => r.litig,
                           :p2p_relation_type_id => r.p2p_relation_type_id
                         )

  end

  after_destroy do |r|
    O2pRelationType.find( r.id ).delete
  end

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

