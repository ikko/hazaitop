class Article < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    title   :text
    summary :text
    weblink :string
    timestamps
  end

#  has_many :article_relations
#  has_many :person_to_org_relations, :through => :article_relations
#  has_many :interpesonal_relations, :through => :article_relations
#  has_many :interorg_relations, :through => :article_relations

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
