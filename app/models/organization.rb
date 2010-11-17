class Organization < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name              :string
    street1           :string
    street2           :string
    zip_code          :string
    trade_register_nr :string
    tax_nr            :string
    start_time        :date
    end_time          :date
    timestamps
  end

  has_many :interorg_relations, :accessible => true
  has_many :person_to_org_relations

  has_many :persons,       :through => :person_to_org_relations, :accessible => true
  has_many :organizations, :through => :person_to_org_relations, :accessible => true
  has_many :related_organizations_a, :through => :interorg_relations, :accessible => true, :source => :organization_a
  has_many :related_organizations_b, :through => :interorg_relations, :accessible => true, :source => :organization_b

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
