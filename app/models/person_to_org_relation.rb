# -*- encoding : utf-8 -*-
class PersonToOrgRelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    start_time :date
    end_time   :date
    no_end_time :boolean, :default => false
    weight     :float,    :default => 1
    visual     :boolean, :default => true
    role   :string    # tisztség complexbol
    role2   :string    # tisztség complexbol névből kiparse-olva
    note   :text
    erased_at :date  # ha a bejegyzés törlés volt a cégbíróságon, akkkor ide a törlés dátuma kerül
    jelentos  :boolean, :default => false
    tobbsegi  :boolean, :default => false
    kozvetlen :boolean, :default => false
    szavazat_50_szazalek_felett  :boolean, :default => false
    szavazat_tobbsegi_befolyas   :boolean, :default => false
    szavazat_egyeduli_reszvenyes :boolean, :default => false
    parsed :boolean, :default => false
    timestamps
  end

  def name
    "#{person} és #{organization}"
  end

  has_many :article_relations, :as => :relationable, :accessible => true
  has_many :articles, :through => :article_relations, :accessible => true

  belongs_to :p2o_relation_type
  belongs_to :o2p_relation_type
  belongs_to :organization, :counter_cache => true
  belongs_to :person, :counter_cache => true

  has_many :interpersonal_relations, :dependent => :destroy
  has_many :other_interpersonal_relations, :class_name => "InterpersonalRelation", :dependent => :destroy, :foreign_key => "other_interpersonal_relation_id"

  belongs_to :information_source

  has_many :litigation_relations, :as => :litigable, :dependent => :destroy
  has_many :litigations, :through => :litigation_relations, :accessible => true
#=begin
  validates_presence_of :p2o_relation_type
  # validates_presence_of :o2p_relation_type
  validate :litigation_related
  validate :source_present

  def source_present
    if information_source.blank? and articles.empty?
      errors.add("Information source", "must present.")
    end
  end


  def litigation_related
    unless litigations.blank?
      errors.add("Litigation allowed only if", "relation type has legal aspect.") unless p2o_relation_type.litig
    end
  end

  before_validation do |r|
    p2o_relation_type_id   = r.o2p_relation_type.pair_id if r.o2p_relation_type
    o2p_relation_type_id   = r.p2o_relation_type.pair_id if r.p2o_relation_type
    r.p2o_relation_type_id = p2o_relation_type_id        if p2o_relation_type_id
    r.o2p_relation_type_id = o2p_relation_type_id        if o2p_relation_type_id
  end

  before_create do |r|
    r.organization.try.increment! :relations_counter
    r.person.try.increment! :relations_counter
    true
  end
    
  before_save do |r|
    r.visual = r.p2o_relation_type.visual
    r.information_source_id = (r.info_id ? r.info_id : r.articles.first.try.information_source_id ) if r.information_source.blank?
    r.information_source_id = InformationSource.find_by_domain_name('ahalo.hu').id if r.information_source.blank?

    true
    # r.weight = r.information_source.weight * r.p2o_relation_type.weight
  end

  after_save do |r|
    r.match
    puts "person_to_org_relation after_save hook running..."
    puts r.inspect
    puts "///////////////////////////////////////////////"
    true
  end

  after_destroy do |r|
    logger.info "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"
    r.organization.try.decrement! :relations_counter
    r.person.try.decrement! :relations_counter
    true
  end
#=end
  def match
    self.interpersonal_relations.try.delete_all
    self.other_interpersonal_relations.try.delete_all
    puts        "----  lofa 1 ---- #{self.id}"
    if person and organization # ha nem törlés történt
    puts        "----  lofa 2 ---- #{self.id}"
      if !(InterpersonalRelation.find_by_person_to_org_relation_id(id) or InterpersonalRelation.find_by_other_person_to_org_relation_id(id))
    puts        "----  lofa 3 ---- #{self.id}"
       # meg kell vizsgálnunk hogy van-e már, különben kétszer megy bele (a hobo?) az after_save-be TODO
        if start_time.nil?
          potential_relations = nil # TODO azért ez itt nem biztos---
        else
          if no_end_time
            potential_relations = PersonToOrgRelation.find( :all, :conditions => [
            "organization_id = ? and ((start_time <= ? and (end_time >= ? or no_end_time = ?)) or (start_time <= ? and no_end_time = ?)) and id != ?", organization_id, start_time, start_time, true, Time.now.to_date, true, id ])
          else
            potential_relations = PersonToOrgRelation.find( :all, :conditions => [
            "organization_id = ? and ((start_time <= ? and (end_time >= ? or no_end_time = ?)) or (start_time <= ? and (end_time >= ? or no_end_time = ?))) and id != ?", organization_id, start_time, start_time, true, end_time, end_time, true, id ])
          end
        end
        press_id = P2oRelationType.find_by_name("sajtó").id
    puts        "----  lofa 4 ---- #{self.id}"
        if potential_relations and p2o_relation_type_id != press_id
    puts        "----  lofa 5 ---- #{self.id}"
          potential_relations.each do |pot|
    puts        "----  lofa 6 ---- #{self.id}"
            unless pot.p2o_relation_type_id == press_id  # sajtós fetcheket nem birizgáljuk
    puts        "----  lofa 7 ---- #{self.id}"
              if person_id != pot.person_id # saját kapcsolatokat nem veszünk fel
                weight = (information_source.weight + pot.information_source.weight) / 2.0
                # nézzük meg, hogy a kalkulátorban rögzítve van-e a két kapcsolattipus (irányított!)
                relation_type_id = InterpersonalRelationCalculator.find_by_p2o_relation_type_id(pot.p2o_relation_type_id)._?.p2p_relation_type_id
                if !relation_type_id
                  # ha megegyezik a két kapcsolat, akkor default-oljunk, a p2p kapcsolattipusukra
                  if p2o_relation_type_id == pot.p2o_relation_type_id
                    relation_type_id = p2o_relation_type.p2p_relation_type_id
                  else
                    # ha nincs info, akkor csak azt rögzítjük, hogy közös intézménynél szerepelnek
                    relation_type_id = P2pRelationType.find(:first, :conditions => {:name => "közös intézményi kapcsolat", :internal => true }).id
                  end
                end
                if start_time <= pot.start_time
                  calculated_start_time = pot.start_time
                else
                  calculated_start_time = start_time
                end
                calculated_no_end_time = false
                if no_end_time and !pot.no_end_time
                  calculated_end_time = pot.end_time
                elsif pot.no_end_time and !no_end_time
                  calculated_end_time = end_time
                elsif no_end_time and pot.no_end_time
                  calculated_end_time = nil
                  calculated_no_end_time = true
                else
                  if end_time <= pot.end_time
                    calculated_end_time = end_time
                  else
                    calculated_end_time = pot.end_time
                  end
                end
                info = InformationSource.find :first, :conditions => { :internal => true, :weight => weight }
                info = InformationSource.create!(:internal => true, :weight => weight, :name => "system", :web => 'http://hazaitop.addig.hu' ) if !info
    puts        "----  lofa 8 ---- #{self.id}"
                interpersonal = InterpersonalRelation.new(:p2p_relation_type_id => relation_type_id,
                                                          :person_id => person_id,
                                                          :related_person_id => pot.person_id,
                                                          :information_source_id => info.id,
                                                          :person_to_org_relation_id => id,
                                                          :other_person_to_org_relation_id => pot.id,
                                                          :organization_id => organization_id,
                                                          :start_time => calculated_start_time,
                                                          :end_time => calculated_end_time,
                                                          :no_end_time => calculated_no_end_time,
                                                          :visual => p2o_relation_type.visual,
                                                          :internal => true)
                interpersonal.articles = articles
    puts        "----  lofa 9 ---- #{self.id}"
                interpersonal.litigations = self.litigations
    puts        "----  lofa 10 ---- #{self.id}"
    puts        interpersonal.save
    puts        "----  lofa 11 ---- #{self.id}"
              end
            end
          end
        end
      end
    else # törlés történt
    puts        "----  lofa 12 ---- #{self.id}"
      self.destroy
    end
  end


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

