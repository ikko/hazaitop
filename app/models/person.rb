# -*- encoding : utf-8 -*-
class Person < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    first_name   :string #, :required
    last_name    :string #, :required
    name         :string
    street       :string
    city         :string
    zip_code     :string
    country      :string
    klink        :string
    born_at      :date
    mothers_name :string
    mothers_name_alternate :string # ha megtaláltuk, de nem biztos, h ő az, akkor ide tesszük complex-ből
    complexed_at :date
    interpersonal_relations_count :integer, :default => 0
    person_to_org_relations_count :integer, :default => 0
    search_result_count           :integer, :default => 0
    relations_counter             :integer, :default => 0
    relations_bit                 :boolean, :default => false
    complex_xml :text
    timestamps
    address :string
    order_name :string
  end

  default_scope  :order => 'order_name' 

  before_save do |r|
    r.normalize_name
    r.clean_name
    if r.name
      r.order_name = r.name
      (%w{id. ifj. dr. Dr. DR.} + ['ifj ', 'id ', 'dr ', 'Dr ', 'DR ']).each do |pre|
        if r.name[0..pre.size-1] == pre
          r.order_name = r.name[pre.size..-1].strip + ' ' + pre
        end
      end
    end
    r.relations_counter = r.interpersonal_relations_count + r.person_to_org_relations_count
    r.relations_bit = true if r.relations_counter > 0
    if r.zip_code.blank? and r.city.blank? and r.street.blank?
      r.address = " "
    else
      r.address = "#{r.zip_code} #{r.city}, #{r.street}" 
    end
  end

  belongs_to :selected_organization, :class_name => "Organization"

  validates_presence_of :information_source

  has_many :person_grade_assocs
  has_many :person_grades, :through => :person_grade_assocs, :accessible => true

  belongs_to :place_of_birth

  # ez az összes kapcsolat, azok is, amit a rendszer generált
  has_many :interpersonal_relations, :accessible => true
  has_many :people, :through => :interpersonal_relations, :source => :related_person

  # ezek csak a kézzel bevitt kapcsolatok
  has_many :personal_relations, :conditions => [ "internal = ?", false], :class_name => "InterpersonalRelation", :accessible => true

  # helperek a vizualicáziós részhez
  has_many :personal_non_litigation_relations, :conditions => [ "visual = ?", true], :class_name => "InterpersonalRelation"
  has_many :personal_litigation_relations, :conditions => [ "visual = ?", false], :class_name => "InterpersonalRelation"
  has_many :person_to_org_non_litigation_relations, :conditions => [ "visual = ?", true], :class_name => "PersonToOrgRelation"
  has_many :person_to_org_litigation_relations, :conditions => [ "visual = ?", false], :class_name => "PersonToOrgRelation"


  # helperek adminhoz
  has_many :manual_interpersonal_relations, :conditions => [ "parsed = ?", false], :class_name => "InterpersonalRelation", :accessible => true
  has_many :manual_person_to_org_relations, :conditions => [ "parsed = ?", false], :class_name => "PersonToOrgRelation", :accessible => true

  has_many :person_to_org_relations, :accessible => true, :order => "organization_id"

  has_many :organizations, :through => :person_to_org_relations

  belongs_to :information_source
  belongs_to :user, :creator => true

  has_many :person_histories

  belongs_to :merge_from, :class_name => "Person"
  
  def to_param
    "#{id}-#{name.to_textual_id}"
  end

  def address
    if zip_code.blank? and city.blank? and street.blank?
      " "
    else
      "#{zip_code} #{city}, #{street}"
    end
  end


  def self.merge into_this, this

    this.person_grade_assocs.each      { |f| f.person_id = into_this.id; f.save(false) }
    this.interpersonal_relations.each  { |f| f.person_id = into_this.id; f.save(false) }
    this.person_to_org_relations.each  { |f| f.person_id = into_this.id; f.save(false) }
    this.person_histories.each         { |f| f.person_id = into_this.id; f.save(false) }
    into_this.save(false)

#   this.person_grade_assocs.destroy_all
#   this.person_to_org_relations.destroy_all
#   this.interpersonal_relations.destroy_all
#   this.person_histories.destroy_all
    this.reload
#    this.destroy

  end

  def find_path a, target, level=3, res=[self]
    return if level == 0
    a.people.each do |p|
      if p == target
        @this << res + [p]
        return
      end
      if !res.include?(p)
        find_path a, target, level-1, ( res + [p] )
      end
    end
  end

  def path_to b
    results = ""
    @this = []
    find_path self, b
    @this.sort! { |a,b| a.size <=> b.size }
    @this.each do |w| results << w.*.linked_name.join('  >  ') + "<br/><br/>" end
    results
  end

  def linked_name
    "<a style='color: #6EA4B0' target='_blank' href='/people/#{id}'>#{name}</a>"
    # css nem tom miért nem muxik
  end

  def normalize_name
    if last_name
      self.name = last_name.to_s.strip + ' ' + first_name.to_s.strip
      if born_at and born_at.year == Time.now.year
        self.born_at = nil
      end
    else
      if name
        names = name.split(' ')
        self.last_name = names[0]
        self.first_name = names[1..-1].join(' ') if names[1]
      end
    end
  end

  def clean_name
    birosag = InformationSource.find_by_name("birosag.hu")
    if name and information_source_id == birosag.id
      puts name.inspect
      exclude = ["( dr.Szunyogh Valériával együtt)", "( együttesen )", "( elnök )", "( önállóan )", "(a kuratóriumi elnökkel együttesen)", "(alkalmazott)", "(együttesen)", "(elnök) önállóan", "(ketten együtt)", "(önálló)", "/ együttesen", "/ együttesen", "/ eln.tag", "/ Elnök kettö együt", "/ elnök önállóan", "/ elnökhelyettes", "/ ketten együtt", "/ kettő együtt", "/ önállóan", "/ pénztáros", "/ titkár", "/együtt", "/együttesen/ *! **!", "/Elnökh. kettö együtt", "/kettö e", "/önállóan", "/önállóan", "a kuratórium elnöke", "a kuratórium titkára", "alelnök", "alelnök", "alelnök (együttesen)", "alelnök (elején is)", "alelnök elnökkel együtt", "által képviselt tulajdonközösség", "az Ügyvezető Testület elnöke", "az Ügyvezető Testület tagja", "döntőbizottsági tag", "döntőbizottsági tag", "együtt", "együttesen", "eln./önáll.", "elnök", "elnök - igazgató", "elnök akadály esetén", "elnök önálló", "elnök önállóan", "elnökh.", "elnökhelyettes", "elnökkel együtt", "elnökségi tag", "értékesítési és marketing igazgató", "és egy társa", "és társai", "és társai", "forgalmi üzemmérnök - üzemigazgató helyettes", "főtitkár", "gazdasági főmunkatárs", "gazdasági vezérigazgató-helyettes", "igazgatósági", "igazgatósági tag", "IT elnök", "IT tag", "It.tag/másik tagga", "képviseleti joga a 16.Pk.61.042/2003/13. sz. végzés alapján szünetel", "ketten együtt", "kettő együtt", "közös", "közös képviselő", "közös képviselő és 4 társa", "közös törzsbetét képviselő", "kuratóriumi elnök", "kuratóriumi tag", "kuratóriumi titkár", "más munkavállaló", "munkavállaló", "önálló", "önállóan", "szállodaigazgató", "szervezési elnökhelyettes", "tag+másik 2 tag", "társelnök", "titkár", "ügyintéőz társelnök", "ügyvezető", "ügyvezető elnök", "üzletrész képv."]
      exclude.each do |w|
        if name.include?( w )
          s = name.split( w )
          self.name = s[0]
          self.name = s[1] if s[1] and s[1].size > s[0].size
          self.last_name = nil
          normalize_name
          PersonToOrgRelation.information_source_id_is(birosag.id).person_id_is(id).each do |rel|
            rel.role = w
            rel.save
          end  
        end
      end
    end
  end

  # --- Permissions --- #
  def create_permitted?
    acting_user.administrator? || (acting_user.editor? && user.id == acting_user.id)
  end

  def update_permitted?
    acting_user.administrator? || acting_user.editor? || acting_user.supervisor?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.supervisor? || acting_user.editor?
  end


  def view_permitted?(field)
    true
  end

end

