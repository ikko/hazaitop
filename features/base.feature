# language: hu

Jellemző:
  Ahhoz hogy elkezdjem használni az alkalmazást
  Én mint új felhasználó
  Megnézem a promó oldalt és engedélyezem az alkalamzást

  Háttér:
    Ha én létezek
    És én be vagyok lépve a hoboba
    És a "start ifindeye" linkre kattintok

  Forgatókönyv: Új kép kiválasztási és feltöltési lehetőség (ha még nincs egy sem feltöltve)
    És a "Settings" linkre kattintok
    Akkor látnom kell a "Select a JPG picture" szöveget
    És látnom kell az "testtest_name" szöveget az "#infoline" elemben

  Forgatókönyv: Új kép feltöltése file-ból (rögtön aktiválódik)
    És a "Settings" linkre kattintok
    Ha kiválasztom a "test/assets/impishgirl_00.jpg" filet az "s3_file_upload" elemben 
    És az "Upload" gombra kattintok
    Akkor látnom kell a "Click and hold the mouse below" szöveget
    És látnom kell a feltöltött képet
    És nem szabad látnom a "click to activate" szöveget az "#activate_link" elemben

  Forgatókönyv: Új rossz kiterjesztésű kép feltöltése file-ból
    És a "Settings" linkre kattintok
    Akkor nem szabad látnom a "Hibás file formátum" szöveget a ".content_body" elemben
    Ha kiválasztom a "test/assets/impishgirl_00.png" filet az "s3_file_upload" elemben 
    Akkor látnom kell a "Hibás file formátum" szöveget
    És az "Upload" gombra kattintok
    Akkor nem szabad látnom a "Click and hold the mouse below" szöveget a "#cropbox_info" elemben
    És látnom kell a "Hibás file formátum" szöveget
    És látnom kell az "Upload" gombot

  @real_upload
  Forgatókönyv: kép kivágása
    És a "Settings" linkre kattintok
    Ha kiválasztom a "test/assets/impishgirl_00.jpg" filet az "s3_file_upload" elemben 
    És az "Upload" gombra kattintok
    Akkor nem szabad látnom a kivágott képet
    Ha a "save" linkre kattintok
    Akkor 1 eye-nek kell léteznie
    És látnom kell az 1. eye kivágott képét
    És a "#saved" kép "width" attributum értéke "300" kell legyen
    És a "#saved" kép "height" attributum értéke "100" kell legyen
    És nem szabad látnom a "click to activate" szöveget az "#activate_link" elemben

  @real_upload
  Forgatókönyv: kis kép kivágása
    És a "Settings" linkre kattintok
    Ha kiválasztom a "test/assets/csaj_play_kicsi.jpg" filet az "s3_file_upload" elemben 
    És az "Upload" gombra kattintok
    Akkor nem szabad látnom a kivágott képet
    Ha a "save" linkre kattintok
    Akkor 1 eye-nek kell léteznie
    És látnom kell az 1. eye kivágott képét
    És a "#saved" kép "width" attributum értéke "300" kell legyen
    És a "#saved" kép "height" attributum értéke "95" és "100" között kell legyen

  Forgatókönyv: kép aktiválási lehetőség ha több kép van
    És a "Settings" linkre kattintok
    Majd kiválasztom a "test/assets/impishgirl_00.jpg" filet az "s3_file_upload" elemben 
    És az "Upload" gombra kattintok
    És a "save" linkre kattintok
    Akkor 1 eye-nak kell léteznie
    És látnom kell az 1. eye kivágott képét
    És nem szabad látnom a "click to activate" szöveget az "#activate_link" elemben
    És a "Settings" linkre kattintok
    Majd kiválasztom a "test/assets/impishgirl_00.jpg" filet az "s3_file_upload" elemben 
    És az "Upload" gombra kattintok
    És a "save" linkre kattintok
    Akkor 2 eye-nak kell léteznie
    És látnom kell az 2. eye kivágott képét
    És látnom kell a "click to activate" szöveget

  @stop_dj
  Forgatókönyv: új kép aktiválása
    És nem vagyok aktiválva
    És a "Settings" linkre kattintok
    Ha kiválasztom a "test/assets/impishgirl_00.jpg" filet az "s3_file_upload" elemben 
    És az "Upload" gombra kattintok
    És 1 eye-nek kell léteznie
    És 1 eye-nek kell léteznie a következőkkel id: 1, selected_for_active: false
    És 1 user-nek kell léteznie a következőkkel first_eye_id: nil, active: false
    És nekem real-actorban még nincs főképem
    Ha a "save" linkre kattintok
    És a "Settings" linkre kattintok
    És 1 eye-nek kell léteznie a következőkkel id: 1, selected_for_active: true
    És 1 user-nek kell léteznie a következőkkel first_eye_id: nil, active: false
    Ha kiválasztom a "test/assets/impishgirl_01.jpg" filet az "s3_file_upload" elemben 
    És nekem real-actorban még nincs főképem
    És az "Upload" gombra kattintok
    Ha a "save" linkre kattintok
    És 2 eye-nek kell léteznie
    És 1 eye-nek kell léteznie a következőkkel id: 1, selected_for_active: true
    És 1 eye-nek kell léteznie a következőkkel id: 2, selected_for_active: false
    És 1 user-nek kell léteznie a következőkkel first_eye_id: nil, active: false
    És nekem real-actorban még nincs főképem
    És a "click to activate" linkre kattintok
    Akkor látnom kell a "There are 2 Eyes" szöveget
    És 2 eye-nek kell léteznie
    És 1 eye-nek kell léteznie a következőkkel id: 1, selected_for_active: false
    És 1 eye-nek kell léteznie a következőkkel id: 2, selected_for_active: true
    És 1 user-nek kell léteznie a következőkkel first_eye_id: nil, active: false
    És nekem real-actorban még nincs főképem
    És látnom kell a "This picture is being prepared for the game. After preparation this will be your active eye." szöveget
    Ha indítjuk a delayed jobot
    És megvárom a rake taskok feldolgozását
    Akkor 1 eye-nek kell léteznie a következőkkel id: 1, selected_for_active: false
    És egy eye: "főkép"-nek kell léteznie a következőkkel id: 2, selected_for_active: false
    És 1 user-nek kell léteznie a következőkkel first_eye_id: 2, active: true
    És nekem real-actorban a főképem eye secretje az eye "főkép"
    
  Forgatókönyv: kép törlése kivágáskor ha még nincs feldolgozva a kép
    És a "Settings" linkre kattintok
    Majd kiválasztom a "test/assets/impishgirl_00.jpg" filet az "s3_file_upload" elemben 
    És az "Upload" gombra kattintok
    És a "save" linkre kattintok
    És az eyes oldalra megyek
    És nem szabad látnom a "Remove" gombot
    És látnom kell a "Feldolgozás alatt..." szöveget

  Forgatókönyv: kép törlése listázásból ha egynél több kép van
    És a "Settings" linkre kattintok
    Majd kiválasztom a "test/assets/impishgirl_00.jpg" filet az "s3_file_upload" elemben 
    És az "Upload" gombra kattintok
    És a "save" linkre kattintok
    És a "Settings" linkre kattintok
    Majd kiválasztom a "test/assets/impishgirl_00.jpg" filet az "s3_file_upload" elemben 
    És az "Upload" gombra kattintok
    És a "save" linkre kattintok
    És a "Settings" linkre kattintok
    És a feltöltött képek már fel vannak dolgozva
    És a "select another from stored" linkre kattintok
    Akkor látnom kell a "There are 2 Eyes" szöveget
    És leokézom a js popupot a következő teszt lépésnél
    És a "Remove" gombra kattintok
    Akkor látnom kell a "There is 1 Eye" szöveget
    
  Forgatókönyv: tube menü működés
    És van aktív képem
    Majd a "Tube" linkre kattintok
    Akkor látnom kell a "Distance" szöveget

  Forgatókönyv: tube menü működés
    És van aktív képem
    Majd a "Tube" linkre kattintok
    És a "Tube" linkre kattintok
    Akkor látnom kell a "Distance" szöveget a "#distance_unit_toggler" elemben js

  @dj
  Forgatókönyv: chat menü működés
    És nem vagyok aktiválva
    És a "Settings" linkre kattintok
    Ha kiválasztom a "test/assets/impishgirl_00.jpg" filet az "s3_file_upload" elemben 
    És az "Upload" gombra kattintok
    Ha a "save" linkre kattintok
    És megvárom a rake taskok feldolgozását
    És a "Chat" linkre kattintok
    Akkor látnom kell a "#send_button" elemet
    Ha a "Chat" linkre kattintok
    És a "Chat" linkre kattintok
    Akkor látnom kell a "#send_button" elemet

  Forgatókönyv: settings menü működés
    És van aktív képem
    És a "Settings" linkre kattintok
    Akkor a new eye oldalon kell legyek
    
  Forgatókönyv: balance menü működés
    És van aktív képem
    És a "Balance" linkre kattintok
    Akkor látnom kell a "Card Number" szöveget
    És látnom kell a "#credit_card_card_number" elemet
    
  # TODO: ezt mindenképp tesztelni FF-ben miért nem submitolja a formot
  @chrome
  Forgatókönyv: felhasználói adatok szerkesztése
    És van aktív képem
    És a "Settings" linkre kattintok
    És a "Settings" linkre kattintok
    És az "Edit User" linkre kattintok
    És a "Female"-t kiválasztom a "user[gender]" elemből
    És kitöltöm a "user_nick" mezőt a következővel "tesztelek"
    És kitöltöm a "user_color" mezőt a következővel "#8154f0"
    És a "Save" gombra kattintok
    Akkor 1 user-nek kell léteznie a következőkkel nick: "tesztelek", color: "#8154f0", gender: "female", interested_in_female: false, interested_in_male: true
    És redisben saját magam "nick"-je "tesztelek" kell legyen

  Forgatókönyv: felhasználói adatok szerkesztése, nem adja meg kik érdeklik
    És van aktív képem
    És a "Settings" linkre kattintok
    És a "Settings" linkre kattintok
    És az "Edit User" linkre kattintok
    És a "user_interested_in_female"-t kicsekkolom
    És a "Save" gombra kattintok
    Akkor 1 user-nek kell léteznie a következőkkel interested_in_female: true, interested_in_male: false
    
  @chrome
  Forgatókönyv: több azonos nickű egyén lehet
    És van aktív képem
    És "Szerafin" a kontaktom
    És a "Settings" linkre kattintok
    És a "Settings" linkre kattintok
    És az "Edit User" linkre kattintok
    És kitöltöm a "user_nick" mezőt a következővel "Szerafin"
    És a "Save" gombra kattintok
    Akkor 2 user-nek kell léteznie a következőkkel nick: "Szerafin"
    
  
  Forgatókönyv: matchelések vizsgálata
  Forgatókönyv: tube userlist vizsgálata
  
  Forgatókönyv: kép zoom-crop módosítása
  Forgatókönyv: facebook profiloldal elérése
  Forgatókönyv: facebook profiloldal adatok frissítése
  Forgatókönyv: barátok meghívása
  Forgatókönyv: egyedi színek működése

