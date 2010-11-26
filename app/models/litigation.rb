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
  belongs_to :information_source

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def update_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.editor?
  end

  def view_permitted?(field)
    true
  end

end
