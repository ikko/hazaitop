class Article < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    title   :text
    summary :text
    internet_address :string, :required
    weblink :string
    timestamps
  end

  belongs_to :information_source

  has_many :article_relations
  
  has_many :person_to_org_relations, 
           :through => :article_relations, 
           :source => :person_to_org_relation, 
           :conditions => "article_relations.relationable_type = 'PersonToOrgRelation'"

  has_many :interorg_relations, 
           :through => :article_relations, 
           :source => :interorg_relation, 
           :conditions => "article_relations.relationable_type = 'InterorgRelation'" 

  has_many :interpersonal_relations, 
           :through => :article_relations, 
           :source => :interpersonal_relation,
           :conditions => "article_relations.relationable_type = 'InterpersonalRelation'" 

  before_save do |article|
    unless article.internet_address.blank?
       d = Domainatrix.parse(article.internet_address)
       domain_name = d.domain + '.' + d.public_suffix
       i = InformationSource.find_or_create_by_domain_name( domain_name ) { |r| r.name = r.domain_name = domain_name; r.weight = 1; r.web = d.host }
       article.information_source_id = i.id 
    end
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || acting_user.supervisor? || acting_user.editor?
  end

  def update_permitted?
    acting_user.administrator? || acting_user.supervisor? || acting_user.editor?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.supervisor? || acting_user.editor?
  end

  def view_permitted?(field)
    true
  end

end
