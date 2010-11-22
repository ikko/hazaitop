# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup or cap:deploy:db).

if P2pRelationType.count == 0

  # egyszerű személyes kapcsolatok
  P2pRelationType.create( :name => "üzleti partner",      :weight => "9" )
  P2pRelationType.create( :name => "barát",               :weight => "6" )
  P2pRelationType.create( :name => "rokon",               :weight => "11" )

  # egyszerűen származtatható személyes kapcsolatok és a forrás intézményi kapcsolatok
  i = P2pRelationType.create( :name => "iskolatárs",      :weight => "3" )
  P2oRelationType.create(     :name   => "diák",          :weight => "6", :p2p_relation_type_id => i.id )
  i = P2pRelationType.create( :name => "kollégiumi társ", :weight => "4" )
  P2oRelationType.create(     :name   => "kollegista",    :weight => "9", :p2p_relation_type_id => i.id )
  i = P2pRelationType.create( :name => "munkatárs",       :weight => "7" )
  P2oRelationType.create(     :name   => "alkalmazott",   :weight => "7",  :p2p_relation_type_id => i.id )
  i = P2pRelationType.create( :name => "párttárs",        :weight => "12" )
  P2oRelationType.create(     :name   => "párttag",       :weight => "14", :p2p_relation_type_id => i.id )
  i = P2pRelationType.create( :name => "társtulajdonos",  :weight => "8" )
  P2oRelationType.create(     :name   => "tulajdonos",    :weight => "10", :p2p_relation_type_id => i.id )
  i = P2pRelationType.create( :name => "IT társ",         :weight => "8" )
  P2oRelationType.create(     :name   => "IT tag",        :weight => "10", :p2p_relation_type_id => i.id )
  i = P2pRelationType.create( :name => "FB társ",         :weight => "8" )
  P2oRelationType.create(     :name   => "FB tag",        :weight => "10", :p2p_relation_type_id => i.id )

end

if O2oRelationType.count == 0

  # egyszerű intézményközi kapcsolatok
  O2oRelationType.create(     :name => "üzleti partner", :weight => "5" )

  # kétoldalú intézményközi kapcsolatok párban
  t = O2oRelationType.create( :name => "anyavállalat",   :weight => "10" )
  r = O2oRelationType.create( :name => "leányválalat",   :weight => "10", :pair_id => t.id )
  t.update_attribute :pair_id, r.id
  t = O2oRelationType.create( :name => "szponzor",       :weight => "10" )
  r = O2oRelationType.create( :name => "szponzorált",    :weight => "10", :pair_id => t.id )
  t.update_attribute :pair_id, r.id

  # p2p kapcsolatot nem eredményező egyszerű személy és szerveztközi kapcsolatok
  P2oRelationType.create( :name => "alvállalkozó",      :weight => "6" )

end


if InformationSource.count == 0

  # információforrások
  InformationSource.create( :name => "közbeszerzési értesítő",  :weight => "15" )
  InformationSource.create( :name => "cégbíróság",              :weight => "15" )
  InformationSource.create( :name => "index.hu",                :weight => "11" )
  InformationSource.create( :name => "origo.hu",                :weight => "11" )
  sajat = InformationSource.create( :name => "saját forrás",            :weight => "20" )

end

if Rails.env == "development"

  if User.count == 0
    User.create :name => "admin", :email_address => "admin@addig.hu", :password => "minek", :password_confirmation => "minek", :editor => false, :administrator => true
    User.create :name => "editor", :email_address => "editor@addig.hu", :password => "minek", :password_confirmation => "minek", :editor => true,
    User.create :name => "supervisor", :email_address => "supervisor@addig.hu", :password => "minek", :password_confirmation => "minek", :editor => true, :supervisor => true
    User.create :name => "normale", :email_address => "normale@addig.hu", :password => "minek", :password_confirmation => "minek", :editor => false, :administrator => false
  end

  if Organization.count == 0
    Organization.create! :name => "szivarvany gyar", :information_source_id => sajat.id
    Organization.create! :name => "gomba gyar", :information_source_id => sajat.id
  end

  if Person.count == 0
    Person.create! :first_name => "kokojszi", :last_name => "torpe", :information_source_id => sajat.id
    Person.create! :first_name => "bobojsza", :last_name => "torpe", :information_source_id => sajat.id
  end

end

if Rails.env == "development"

  if User.count == 0
    User.create :name => "Béky Miklós", :email_address => "miklos.beky@gmail.com", :password => "asdf1234", :password_confirmation => "asdf1234", :editor => false, :administrator => true
    User.create :name => "Komzák Nándor", :email_address => "nandor.komzak@gmail.com", :password => "asdf1234", :password_confirmation => "asdf1234", :editor => false, :administrator => true
    User.create :name => "Léderer Sándor", :email_address => "lederer@k-monitor.hu", :password => "probababa", :password_confirmation => "probababa", :editor => true, :supervisor => true
    User.create :name => "Keserű Júlia", :email_address => "keseru.julia@k-monitor.hu", :password => "probababa", :password_confirmation => "probababa", :editor => true, :supervisor => true
  end

  if Organization.count == 0
    Organization.create! :name => "szivarvany gyar", :information_source_id => sajat.id
    Organization.create! :name => "gomba gyar", :information_source_id => sajat.id
  end

  if Person.count == 0
    Person.create! :first_name => "kokojszi", :last_name => "torpe", :information_source_id => sajat.id
    Person.create! :first_name => "bobojsza", :last_name => "torpe", :information_source_id => sajat.id
  end

end

if Rails.env == "production"

  if User.count == 0
    User.create :name => "Béky Miklós", :email_address => "miklos.beky@gmail.com", :password => "asdf1234", :password_confirmation => "asdf1234", :editor => false, :administrator => true
    User.create :name => "Komzák Nándor", :email_address => "nandor.komzak@gmail.com", :password => "asdf1234", :password_confirmation => "asdf1234", :editor => false, :administrator => true
    User.create :name => "Léderer Sándor", :email_address => "lederer@k-monitor.hu", :password => "probababa", :password_confirmation => "probababa", :editor => true, :supervisor => true
    User.create :name => "Keserű Júlia", :email_address => "keseru.julia@k-monitor.hu", :password => "probababa", :password_confirmation => "probababa", :editor => true, :supervisor => true
  end


  if Organization.count == 0
    Organization.create! :name => "Szivarvany Gyár", :information_source_id => sajat.id
    Organization.create! :name => "Gomba Gyár", :information_source_id => sajat.id
  end

  if Person.count == 0
    Person.create! :first_name => "Géza", :last_name => "Cérna", :information_source_id => sajat.id
    Person.create! :first_name => "Mátyás", :last_name => "Mókás", :information_source_id => sajat.id
  end

end