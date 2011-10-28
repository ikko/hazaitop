# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup or cap:deploy:db).


if PersonGrade.count == 0
  PersonGrade.create :name => "politikus"
  PersonGrade.create :name => "üzletember"
  PersonGrade.create :name => "közhivatalnok"
end

if OrgGrade.count == 0
  OrgGrade.create :name => "minisztérium"
  OrgGrade.create :name => "hatóság"
  OrgGrade.create :name => "állami cég"
  OrgGrade.create :name => "magáncég"
  OrgGrade.create :name => "párt"
  org = OrgGrade.create :name => "non-profit szervezet"
  OrgGrade.create :name => "off-shore cég"
  OrgGrade.create :name => "egyéb"
end

if Activity.count == 0
  Activity.create :name => "szolgáltatás"
  Activity.create :name => "kereskedelem"
  Activity.create :name => "ipar"
end

if Sector.count == 0
  Sector.create :name => "pénzügyi és biztosítási szolgáltatás"
  Sector.create :name => "építőipar, szolgáltatás és kereskedelem"
  Sector.create :name => "autó- és autóalkatrész, jármű- és járműalkatrész-gyártás"
  Sector.create :name => "távközlés, posta- és internetszolgáltatás"
  Sector.create :name => "nagykereskedelem"
  Sector.create :name => "elektronikai ipar"
  Sector.create :name => "gyógyszeripar"
  Sector.create :name => "fuvarozás, szállítmányozás"
  Sector.create :name => "építő- és építőanyagipar, fafeldolgozás, síküveggyártás"
  Sector.create :name => "fémfeldolgozás"
  Sector.create :name => "gépgyártás"
  Sector.create :name => "kiskereskedelem"
  Sector.create :name => "élelmiszeripar és mezőgazdaság"
  Sector.create :name => "dohányipar"
  Sector.create :name => "vegy-, gumi- és műanyagipar"
  Sector.create :name => "ruházati, papír- és nyomdaipar"
  Sector.create :name => "egyéb szolgáltatás"
end

if P2pRelationType.count == 0

  P2pRelationType.create(:name => "közös intézményi kapcsolat", :internal => true)

  # egyszerű személyes kapcsolatok
  P2pRelationType.create( :name => "üzleti partner",      :weight => "9" )
  P2pRelationType.create( :name => "barát",               :weight => "6" )
  P2pRelationType.create( :name => "rokon",               :weight => "11" )
  f = P2pRelationType.create( :name => "közös sajtó",   :weight => "1" )

  # kétoldalú nem származtatott személyes kapcsolatok
  a = P2pRelationType.create( :name => "alperes",         :weight => "10", :visual => false, :litig => true )
  b = P2pRelationType.create( :name => "felperes",        :weight => "10",   :pair_id => a.id, :visual => false, :litig => true  )
  a.update_attribute :pair_id, b.id

  a = P2pRelationType.create( :name => "hitelező",         :weight => "20" )
  b = P2pRelationType.create( :name => "adós",             :weight => "20",   :pair_id => a.id  )
  a.update_attribute :pair_id, b.id

  # intézményi kapcsolatból származtatható személyes kapcsolatok és a forrás intézményi kapcsolatok
  
  a = P2oRelationType.create(     :name   => "közös sajtó",       :weight => "1", :p2p_relation_type_id => f.id )
  b = O2pRelationType.create(     :name   => "közös sajtó",       :weight => "1", :p2p_relation_type_id => f.id, :pair_id => a.id  )
  a.update_attribute :pair_id, b.id
  
  i = P2pRelationType.create( :name => "iskolatárs",      :weight => "3", :internal => true )
  a = P2oRelationType.create(     :name   => "diák",         :weight => "6", :p2p_relation_type_id => i.id)
  b = O2pRelationType.create(     :name   => "tanuló",       :weight => "6", :p2p_relation_type_id => i.id, :pair_id => a.id  )
  a.update_attribute :pair_id, b.id

  i = P2pRelationType.create( :name => "kollégiumi társ", :weight => "4", :internal => true )
  a = P2oRelationType.create(     :name   => "kollegista",   :weight => "9", :p2p_relation_type_id => i.id )
  b = O2pRelationType.create(     :name   => "kollegista",   :weight => "9", :p2p_relation_type_id => i.id, :pair_id => a.id  )
    a.update_attribute :pair_id, b.id

  i = P2pRelationType.create( :name => "munkatárs",       :weight => "7", :internal => true )
  a = P2oRelationType.create(     :name   => "munkavállaló",  :weight => "7",  :p2p_relation_type_id => i.id )
  b = O2pRelationType.create(     :name   => "munkaadó", :weight => "7", :p2p_relation_type_id => i.id, :pair_id => a.id  )
  a.update_attribute :pair_id, b.id

  i = P2pRelationType.create( :name => "párttárs",        :weight => "12", :internal => true )
  a = P2oRelationType.create(     :name   => "párttag",      :weight => "14", :p2p_relation_type_id => i.id )
  b = O2pRelationType.create(     :name   => "párttag",      :weight => "14", :p2p_relation_type_id => i.id, :pair_id => a.id  )
  a.update_attribute :pair_id, b.id

  i = P2pRelationType.create( :name => "társtulajdonos",  :weight => "8", :internal => true )
  a = P2oRelationType.create(     :name   => "tulajdonos",   :weight => "10", :p2p_relation_type_id => i.id )
  b = O2pRelationType.create(     :name   => "tulajdonos",   :weight => "10", :p2p_relation_type_id => i.id, :pair_id => a.id  )
  a.update_attribute :pair_id, b.id

  i = P2pRelationType.create( :name => "IT társ",         :weight => "8", :internal => true )
  a = P2oRelationType.create(     :name   => "IT tag",       :weight => "10", :p2p_relation_type_id => i.id )
  b = O2pRelationType.create(     :name   => "IT tag",       :weight => "10", :p2p_relation_type_id => i.id, :pair_id => a.id  )
  a.update_attribute :pair_id, b.id

  i = P2pRelationType.create( :name => "FB társ",         :weight => "8", :internal => true )
  a = P2oRelationType.create(     :name   => "FB tag",       :weight => "10", :p2p_relation_type_id => i.id )
  b = O2pRelationType.create(     :name   => "FB tag",       :weight => "10", :p2p_relation_type_id => i.id, :pair_id => a.id  )
  a.update_attribute :pair_id, b.id

  i = P2pRelationType.create( :name => "egyidejű alperesek",       :weight => "8", :internal => true )
  a = P2oRelationType.create(     :name   => "alperes",      :weight => "10", :p2p_relation_type_id => i.id, :visual => false, :litig => true )
  b = O2pRelationType.create(     :name   => "felperes",     :weight => "10", :p2p_relation_type_id => i.id, :pair_id => a.id, :visual => false, :litig => true  )
  a.update_attribute :pair_id, b.id

  i = P2pRelationType.create( :name => "egyidejű felperesek",      :weight => "8", :internal => true )
  a = P2oRelationType.create(     :name   => "felperes",     :weight => "10", :p2p_relation_type_id => i.id, :visual => false, :litig => true )
  b = O2pRelationType.create(     :name   => "alperes",      :weight => "10", :p2p_relation_type_id => i.id, :pair_id => a.id, :visual => false, :litig => true  )
  a.update_attribute :pair_id, b.id

end

if O2oRelationType.count == 0

  # egyszerű intézményközi kapcsolatok
  O2oRelationType.create(     :name => "üzleti partner", :weight => "5" )
  O2oRelationType.create(     :name => "közös sajtó", :weight => "1" )

  # kétoldalú intézményközi kapcsolatok párban
  t = O2oRelationType.create( :name => "anyavállalat",   :weight => "10" )
  r = O2oRelationType.create( :name => "leányválalat",   :weight => "10", :pair_id => t.id )
  t.update_attribute :pair_id, r.id
  t = O2oRelationType.create( :name => "szponzor",       :weight => "10" )
  r = O2oRelationType.create( :name => "szponzorált",    :weight => "10", :pair_id => t.id )
  t.update_attribute :pair_id, r.id
  t = O2oRelationType.create( :name => "alperes",        :weight => "10", :visual => false, :litig => true )
  r = O2oRelationType.create( :name => "felperes",       :weight => "10", :pair_id => t.id, :visual => false, :litig => true )
  t.update_attribute :pair_id, r.id
  t = O2oRelationType.create( :name => "alvállalkozó",   :weight => "10" )
  r = O2oRelationType.create( :name => "fővállalkozó",   :weight => "10", :pair_id => t.id )
  t.update_attribute :pair_id, r.id
  t = O2oRelationType.create( :name => "közbeszerző",     :weight => "1" )
  r = O2oRelationType.create( :name => "közbesz nyertes", :weight => "1", :pair_id => t.id )
  t.update_attribute :pair_id, r.id


  # p2p kapcsolatot nem eredményező egyszerű személy és szerveztközi kapcsolatok
  P2oRelationType.create( :name => "alvállalkozó",      :weight => "6" )

end


if InformationSource.count == 0

  # információforrások
  InformationSource.create( :name => "közbeszerzési értesítő",  :weight => "14" )
  InformationSource.create( :name => "cégbíróság",              :weight => "15" )
  InformationSource.create( :name => "index.hu",                :weight => "11", :web => "http://www.index.hu" )
  InformationSource.create( :name => "k-monitor.hu",            :weight => "08", :web => "http://www.k-monitor.hu" )
  InformationSource.create( :name => "origo.hu",                :weight => "11", :web => "http://www.origo.hu" )
  sajat = InformationSource.create( :name => "saját forrás",    :weight => "20" )

end

if Rails.env == "development"

  if User.count == 0
    User.create :name => "admin", :email_address => "admin@addig.hu", :password => "minek", :password_confirmation => "minek", :editor => false, :administrator => true
    User.create :name => "editor", :email_address => "editor@addig.hu", :password => "minek", :password_confirmation => "minek", :editor => true
    User.create :name => "supervisor", :email_address => "supervisor@addig.hu", :password => "minek", :password_confirmation => "minek", :editor => true, :supervisor => true
    User.create :name => "normale", :email_address => "normale@addig.hu", :password => "minek", :password_confirmation => "minek", :editor => false, :administrator => false
  end

end


if Rails.env == "production"

  if User.count == 0
#    User.create :name => "adminuser", :email_address => "adminuser@addig.hu", :password => "mitminek", :password_confirmation => "mitminek", :editor => false, :administrator => true, :state => "active"
  end


if Organization.count == 0
   Organization.create! :name => "szivarvany gyár", :information_source_id => sajat.id, :org_grade_id => org.id
   Organization.create! :name => "gomba gyár", :information_source_id => sajat.id, :org_grade_id => org.id
end

if Person.count == 0
   Person.create! :first_name => "géza", :last_name => "cérna", :information_source_id => sajat.id
   Person.create! :first_name => "mátyás", :last_name => "mókás", :information_source_id => sajat.id
end

end

if PlaceOfBirth.count == 0

  PlaceOfBirth.create([
    { :name => 'Abádszalók' },
    { :name => 'Abaújszántó' },
    { :name => 'Abony' },
    { :name => 'Ács' },
    { :name => 'Adony' },
    { :name => 'Ajka' },
    { :name => 'Albertirsa' },
    { :name => 'Alsózsolca' },
    { :name => 'Aszód' },
    { :name => 'Bábolna' },
    { :name => 'Bácsalmás' },
    { :name => 'Badacsonytomaj' },
    { :name => 'Baja' },
    { :name => 'Baktalórántháza' },
    { :name => 'Balassagyarmat' },
    { :name => 'Balatonalmádi' },
    { :name => 'Balatonboglár' },
    { :name => 'Balatonföldvár' },
    { :name => 'Balatonfüred' },
    { :name => 'Balatonfűzfő' },
    { :name => 'Balatonkenese' },
    { :name => 'Balatonlelle' },
    { :name => 'Balkány' },
    { :name => 'Balmazújváros' },
    { :name => 'Barcs' },
    { :name => 'Bátaszék' },
    { :name => 'Bátonyterenye' },
    { :name => 'Battonya' },
    { :name => 'Békés' },
    { :name => 'Békéscsaba' },
    { :name => 'Bélapátfalva' },
    { :name => 'Beled' },
    { :name => 'Berettyóújfalu' },
    { :name => 'Berhida' },
    { :name => 'Biatorbágy' },
    { :name => 'Bicske' },
    { :name => 'Biharkeresztes' },
    { :name => 'Bodajk' },
    { :name => 'Bóly' },
    { :name => 'Bonyhád' },
    { :name => 'Borsodnádasd' },
    { :name => 'Budakalász' },
    { :name => 'Budakeszi' },
    { :name => 'Budaörs' },
    { :name => 'Budapest' },
    { :name => 'Bük' },
    { :name => 'Cegléd' },
    { :name => 'Celldömölk' },
    { :name => 'Cigánd' },
    { :name => 'Csanádpalota' },
    { :name => 'Csenger' },
    { :name => 'Csepreg' },
    { :name => 'Csongrád' },
    { :name => 'Csorna' },
    { :name => 'Csorvás' },
    { :name => 'Csurgó' },
    { :name => 'Dabas' },
    { :name => 'Debrecen' },
    { :name => 'Demecser' },
    { :name => 'Derecske' },
    { :name => 'Dévaványa' },
    { :name => 'Devecser' },
    { :name => 'Dombóvár' },
    { :name => 'Dombrád' },
    { :name => 'Dorog' },
    { :name => 'Dunaföldvár' },
    { :name => 'Dunaharaszti' },
    { :name => 'Dunakeszi' },
    { :name => 'Dunaújváros' },
    { :name => 'Dunavarsány' },
    { :name => 'Dunavecse' },
    { :name => 'Edelény' },
    { :name => 'Eger' },
    { :name => 'Elek' },
    { :name => 'Emőd' },
    { :name => 'Encs' },
    { :name => 'Enying' },
    { :name => 'Ercsi' },
    { :name => 'Érd' },
    { :name => 'Esztergom' },
    { :name => 'Fehérgyarmat' },
    { :name => 'Felsőzsolca' },
    { :name => 'Fertőd' },
    { :name => 'Fertőszentmiklós' },
    { :name => 'Fonyód' },
    { :name => 'Fót' },
    { :name => 'Füzesabony' },
    { :name => 'Füzesgyarmat' },
    { :name => 'Gárdony' },
    { :name => 'Göd' },
    { :name => 'Gödöllő' },
    { :name => 'Gönc' },
    { :name => 'Gyál' },
    { :name => 'Gyomaendrőd' },
    { :name => 'Gyömrő' },
    { :name => 'Gyöngyös' },
    { :name => 'Gyönk' },
    { :name => 'Győr' },
    { :name => 'Gyula' },
    { :name => 'Hajdúböszörmény' },
    { :name => 'Hajdúdorog' },
    { :name => 'Hajdúhadház' },
    { :name => 'Hajdúnánás' },
    { :name => 'Hajdúsámson' },
    { :name => 'Hajdúszoboszló' },
    { :name => 'Hajós' },
    { :name => 'Halásztelek' },
    { :name => 'Harkány' },
    { :name => 'Hatvan' },
    { :name => 'Herend' },
    { :name => 'Heves' },
    { :name => 'Hévíz' },
    { :name => 'Hódmezővásárhely' },
    { :name => 'Ibrány' },
    { :name => 'Igal' },
    { :name => 'Isaszeg' },
    { :name => 'Izsák' },
    { :name => 'Jánoshalma' },
    { :name => 'Jánossomorja' },
    { :name => 'Jászapáti' },
    { :name => 'Jászárokszállás' },
    { :name => 'Jászberény' },
    { :name => 'Jászfényszaru' },
    { :name => 'Jászkisér' },
    { :name => 'Kaba' },
    { :name => 'Kadarkút' },
    { :name => 'Kalocsa' },
    { :name => 'Kaposvár' },
    { :name => 'Kapuvár' },
    { :name => 'Karcag' },
    { :name => 'Kazincbarcika' },
    { :name => 'Kecel' },
    { :name => 'Kecskemét' },
    { :name => 'Kemecse' },
    { :name => 'Kenderes' },
    { :name => 'Kerekegyháza' },
    { :name => 'Keszthely' },
    { :name => 'Kisbér' },
    { :name => 'Kisköre' },
    { :name => 'Kiskőrös' },
    { :name => 'Kiskunfélegyháza' },
    { :name => 'Kiskunhalas' },
    { :name => 'Kiskunmajsa' },
    { :name => 'Kistarcsa' },
    { :name => 'Kistelek' },
    { :name => 'Kisújszállás' },
    { :name => 'Kisvárda' },
    { :name => 'Komádi' },
    { :name => 'Komárom' },
    { :name => 'Komló' },
    { :name => 'Kozármisleny' },
    { :name => 'Körmend' },
    { :name => 'Körösladány' },
    { :name => 'Kőszeg' },
    { :name => 'Kunhegyes' },
    { :name => 'Kunszentmárton' },
    { :name => 'Kunszentmiklós' },
    { :name => 'Lábatlan' },
    { :name => 'Lajosmizse' },
    { :name => 'Lengyeltóti' },
    { :name => 'Lenti' },
    { :name => 'Létavértes' },
    { :name => 'Letenye' },
    { :name => 'Lőrinci' },
    { :name => 'Maglód' },
    { :name => 'Mágocs' },
    { :name => 'Makó' },
    { :name => 'Mándok' },
    { :name => 'Marcali' },
    { :name => 'Máriapócs' },
    { :name => 'Martfű' },
    { :name => 'Martonvásár' },
    { :name => 'Mátészalka' },
    { :name => 'Medgyesegyháza' },
    { :name => 'Mélykút' },
    { :name => 'Mezőberény' },
    { :name => 'Mezőcsát' },
    { :name => 'Mezőhegyes' },
    { :name => 'Mezőkeresztes' },
    { :name => 'Mezőkovácsháza' },
    { :name => 'Mezőkövesd' },
    { :name => 'Mezőtúr' },
    { :name => 'Mindszent' },
    { :name => 'Miskolc' },
    { :name => 'Mohács' },
    { :name => 'Monor' },
    { :name => 'Mór' },
    { :name => 'Mórahalom' },
    { :name => 'Mosonmagyaróvár' },
    { :name => 'Nádudvar' },
    { :name => 'Nagyatád' },
    { :name => 'Nagybajom' },
    { :name => 'Nagyecsed' },
    { :name => 'Nagyhalász' },
    { :name => 'Nagykálló' },
    { :name => 'Nagykanizsa' },
    { :name => 'Nagykáta' },
    { :name => 'Nagykőrös' },
    { :name => 'Nagymányok' },
    { :name => 'Nagymaros' },
    { :name => 'Nyékládháza' },
    { :name => 'Nyergesújfalu' },
    { :name => 'Nyíradony' },
    { :name => 'Nyírbátor' },
    { :name => 'Nyíregyháza' },
    { :name => 'Nyírlugos' },
    { :name => 'Nyírmada' },
    { :name => 'Nyírtelek' },
    { :name => 'Ócsa' },
    { :name => 'Orosháza' },
    { :name => 'Oroszlány' },
    { :name => 'Ózd' },
    { :name => 'Őriszentpéter' },
    { :name => 'Örkény' },
    { :name => 'Pacsa' },
    { :name => 'Paks' },
    { :name => 'Pálháza' },
    { :name => 'Pannonhalma' },
    { :name => 'Pápa' },
    { :name => 'Pásztó' },
    { :name => 'Pécel' },
    { :name => 'Pécs' },
    { :name => 'Pécsvárad' },
    { :name => 'Pétervására' },
    { :name => 'Pilis' },
    { :name => 'Pilisvörösvár' },
    { :name => 'Polgár' },
    { :name => 'Polgárdi' },
    { :name => 'Pomáz' },
    { :name => 'Pusztaszabolcs' },
    { :name => 'Putnok' },
    { :name => 'Püspökladány' },
    { :name => 'Rácalmás' },
    { :name => 'Ráckeve' },
    { :name => 'Rakamaz' },
    { :name => 'Rákóczifalva' },
    { :name => 'Répcelak' },
    { :name => 'Rétság' },
    { :name => 'Rudabánya' },
    { :name => 'Sajóbábony' },
    { :name => 'Sajószentpéter' },
    { :name => 'Salgótarján' },
    { :name => 'Sándorfalva' },
    { :name => 'Sárbogárd' },
    { :name => 'Sarkad' },
    { :name => 'Sárospatak' },
    { :name => 'Sárvár' },
    { :name => 'Sásd' },
    { :name => 'Sátoraljaújhely' },
    { :name => 'Sellye' },
    { :name => 'Siklós' },
    { :name => 'Simontornya' },
    { :name => 'Siófok' },
    { :name => 'Solt' },
    { :name => 'Soltvadkert' },
    { :name => 'Sopron' },
    { :name => 'Sümeg' },
    { :name => 'Szabadszállás' },
    { :name => 'Szarvas' },
    { :name => 'Százhalombatta' },
    { :name => 'Szécsény' },
    { :name => 'Szeged' },
    { :name => 'Szeghalom' },
    { :name => 'Székesfehérvár' },
    { :name => 'Szekszárd' },
    { :name => 'Szendrő' },
    { :name => 'Szentendre' },
    { :name => 'Szentes' },
    { :name => 'Szentgotthárd' },
    { :name => 'Szentlőrinc' },
    { :name => 'Szerencs' },
    { :name => 'Szigethalom' },
    { :name => 'Szigetszentmiklós' },
    { :name => 'Szigetvár' },
    { :name => 'Szikszó' },
    { :name => 'Szob' },
    { :name => 'Szolnok' },
    { :name => 'Szombathely' },
    { :name => 'Tab' },
    { :name => 'Tamási' },
    { :name => 'Tápiószele' },
    { :name => 'Tapolca' },
    { :name => 'Tata' },
    { :name => 'Tatabánya' },
    { :name => 'Téglás' },
    { :name => 'Tét' },
    { :name => 'Tiszacsege' },
    { :name => 'Tiszaföldvár' },
    { :name => 'Tiszafüred' },
    { :name => 'Tiszakécske' },
    { :name => 'Tiszalök' },
    { :name => 'Tiszaújváros' },
    { :name => 'Tiszavasvári' },
    { :name => 'Tokaj' },
    { :name => 'Tolna' },
    { :name => 'Tompa' },
    { :name => 'Tótkomlós' },
    { :name => 'Tököl' },
    { :name => 'Törökbálint' },
    { :name => 'Törökszentmiklós' },
    { :name => 'Tura' },
    { :name => 'Túrkeve' },
    { :name => 'Újfehértó' },
    { :name => 'Újkígyós' },
    { :name => 'Újszász' },
    { :name => 'Üllő' },
    { :name => 'Vác' },
    { :name => 'Vaja' },
    { :name => 'Vámospércs' },
    { :name => 'Várpalota' },
    { :name => 'Vásárosnamény' },
    { :name => 'Vasvár' },
    { :name => 'Vecsés' },
    { :name => 'Velence' },
    { :name => 'Vép' },
    { :name => 'Veresegyház' },
    { :name => 'Veszprém' },
    { :name => 'Vésztő' },
    { :name => 'Villány' },
    { :name => 'Visegrád' },
    { :name => 'Záhony' },
    { :name => 'Zalaegerszeg' },
    { :name => 'Zalakaros' },
    { :name => 'Zalalövő' },
    { :name => 'Zalaszentgrót' },
    { :name => 'Zamárdi' },
    { :name => 'Zirc' },
    { :name => 'Zsámbék' }
  ])

end


