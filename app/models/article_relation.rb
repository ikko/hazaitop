class ArticleRelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields 

  belongs_to :relationable, :polymorphic => true
  belongs_to :article

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
