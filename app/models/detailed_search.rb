class DetailedSearch < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    query        :string
    date_from    :date
    date_to      :date
    person       :boolean, :default => true
    organization :boolean, :default => true
    article      :boolean, :default => true
    litigation   :boolean, :default => true
    amount_from  :integer
    amount_to    :integer
    transaction  :boolean
  end

  has_many :detailed_search_place_of_births
  has_many :place_of_births, :through => :detailed_search_place_of_births, :accessible => true
  has_many :detailed_search_activities
  has_many :activities, :through=>:detailed_search_activities, :accessible => true
  has_many :detailed_search_sectors
  has_many :sectors, :through => :detailed_search_sectors, :accessible => true

  has_many :detailed_search_relations, :accessible => true
  has_many :relations, :through => :detailed_search_relations, :accessible => true

  # --- Permissions --- #

  def create_permitted?
    true
  end

  def update_permitted?
    true
  end

  def destroy_permitted?
    true
  end

  def view_permitted?(field)
    true
  end

end
