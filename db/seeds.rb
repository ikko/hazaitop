# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup or cap:deploy:db).

if P2pRelationType.count == 0
  P2pRelationType.create( :name => "cégtárs",           :weight => "10" )
  P2pRelationType.create( :name => "üzleti partner",    :weight => "9" )
  P2pRelationType.create( :name => "párttag",           :weight => "8" )
  P2pRelationType.create( :name => "munkatárs",         :weight => "7" )
  P2pRelationType.create( :name => "barát",             :weight => "6" )
  P2pRelationType.create( :name => "rokon",             :weight => "11" )
  P2pRelationType.create( :name => "iskolatárs",        :weight => "4" )
  P2pRelationType.create( :name => "kollégiumi társ",   :weight => "3" )
end

if O2oRelationType.count == 0
  t = O2oRelationType.create( :name => "anyavállalat",      :weight => "10" )
  r = O2oRelationType.create( :name => "leányválalat",      :weight => "10", :pair_id => t.id )
  t.update_attribute :pair_id, r.id
  t = O2oRelationType.create( :name => "szponzor",          :weight => "10" )
  r = O2oRelationType.create( :name => "szponzorált",       :weight => "10", :pair_id => t.id )
  t.update_attribute :pair_id, r.id
      O2oRelationType.create( :name => "üzleti partner",    :weight => "5" )
end

if P2oRelationType.count == 0
  P2oRelationType.create( :name => "tulajdonos",        :weight => "10" )
  P2oRelationType.create( :name => "IT tag",            :weight => "9" )
  P2oRelationType.create( :name => "FB tag",            :weight => "8" )
  P2oRelationType.create( :name => "alkalmazott",       :weight => "7" )
  P2oRelationType.create( :name => "alvállalkozó",      :weight => "6" )
end

if InformationSource.count == 0
  InformationSource.create( :name => "közbeszerzési értesítő",  :weight => "15" )
  InformationSource.create( :name => "cégbíróság",              :weight => "15" )
  InformationSource.create( :name => "index.hu",                :weight => "11" )
  InformationSource.create( :name => "origo.hu",                :weight => "11" )
  InformationSource.create( :name => "saját forrás",            :weight => "20" )
end