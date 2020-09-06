//
// Senso (Spiel) Implementierung by YvoPet
// HSPascal 2.1.0 Compiler, PalmOS 3.5 oder höher
//
// Es ist für den Cache weder hilfreich noch nötig diesen Code zu lesen,
// ihr werdet die Koordinaten hier nicht finden! (die sind "ausgelagert")
// Die Veröffentlichung des Codes ist nur als Info für alle Technik-Interessierten gedacht.
//
// History
// -------
// 30.06.2013 v1.00  Anwendung fertigestellt
// 01.09.2013 v1.01  Erweiterung der Akkuanzeige, Eventbufferflush
// 02.09.2013 v1.01a Anpassung der Erweiterung an Zielhardware, Kalibrierung
// 04.09.2013 v1.02  Umgestellt auf Eventhandler, reaktivierung aus standby geht zurück zum startscreen
// 06.09.2013 v1.02a Tasten anderer Geräte sperren, Messagedialoge entfernt
// 26.01.2014 v1.02b Textkonstanten ausgelagert
// 12.07.2014 v1.03  Startlogo implementiert
// 07.06.2015 v1.04  Start-/SpielCounter implementiert
//

// 
// Der Code kann unter MPL 2.0 frei verwendet werden. 
// Eine Erwähnung oder eine Paypal Spende an webmaster@peter-ebe.de wären jedoch eine nette Geste :)
//

Program Senso;

{$SearchPath Units; Units\UI; Units\System}
{$ApplName Senso,YVOPET}
// YVOPET is a referenced PalmOS CreatorID (http://dev.palmos.com/creatorid/)

Uses
  Window, Form, Menu, Rect, Event, SysEvent, SystemMgr, FloatMgr, HSUtils,
  TimeMgr, Preferences, SystemResources, Crt, Chars, SoundMgr,
  TextConsts, Util, Eventhandler, Logo, BitmapUtil;

// ----------------------------------------------------

Resource
  (*
  MenuRes=(ResMBAR,,
    (ResMPUL,(6,14,90,38),(4,0,35,12),'Spiel',
      MenuNewGame=(,'N','Neu Starten')),
    (ResMPUL,(42,14,70,38),(40,0,30,12),'?',
      MenuAbout=(,'I','Info'))
          );
  *)

  MainForm=(ResTFRM,1000,(0,0,160,160),0,0,0(*MenuRes*), (FormTitle,'Geocache by YvoPet'),
    MainSButton=(FormButton,,(16,138,36,12),,,,'Sissi'),
    MainNButton=(FormButton,,(60,138,36,12),,,,'Normal'),
    MainPButton=(FormButton,,(104,138,36,12),,,,'Profi')
           );

// Achtung: Dialog regulär nicht verwenden, ermöglichen das herausspringen aus der Anwendung
//          da dort der normale eventhandler ohne filter greift

//  DlgDebug1  = (ResTalt,,1,0,1,'Debug','Debug Haltepunkt 1','Ok');
//  DlgDebug2  = (ResTalt,,1,0,1,'Debug','Debug Haltepunkt 2','Ok');
//  DlgDebug3  = (ResTalt,,1,0,1,'Debug','Debug Haltepunkt 3','Ok');

// ----------------------------------------------------

type RGameMode=(gmEasy,gmNormal,gmHard);
     RGameState=(gsStart,gsRunPC,gsRunUser,gsLoose,gsWon);

const sVersion = 'v1.04      ';
      iinfpos  = 120;

      iseqleneasy     = 6;
      isoundleneasy   = 300;
      iseqlennormal   = 10;
      isoundlennormal = 250;
      iseqlenhard     = 15;
      isoundlenhard   = 250;

      iMaxArray=1023;

      xMitte    = 80;
      yMitte    = 70;
      xBreite   = 70;
      yBreite   = 50;


var WorkRect:   RectangleType;
    MyMenu:     MenuBarPtr;
    GameMode:   RGameMode;
    GameState:  RGameState;

    LastBatteryupdate: UInt32;
    StartCount:        UInt32;
    PlayCount:         UInt32;

    WerteArray : Array[0..iMaxArray] of Byte;
    aktstart   : integer;
    aktstop    : integer;
    aktpos     : integer;
    aktlen     : integer;


// ----------------------------------------------------

Function InWorkRect(var Event: EventType): Boolean;
begin
  with Event do
    InWorkRect:= RctPtInRectangle(ScreenX, ScreenY, WorkRect);
end;

// ----------------------------------------------------

procedure Visu(iPos:Integer; bHighlight:Boolean);
var r:RectangleType;
    isoundlen:integer;
    idelaylen:integer;
begin
  case gamemode of
    gmeasy:   begin
               isoundlen:= isoundleneasy;
               idelaylen:= isoundleneasy;
              end;
    gmnormal: begin;
               isoundlen:= isoundlennormal;
               idelaylen:= isoundlennormal;
              end;
    gmhard:   begin
               isoundlen:= isoundlenhard;
               idelaylen:= isoundlenhard;
              end;
  end;

  if WinSetDrawMode(winPaint) > 0 then begin end;
  case iPos of

    0: begin
        if bhighlight then
        begin
         WinDrawChars(sTaste,length(sTaste), xmitte-45, ymitte-35);
         DoSound(800,isoundlen);
        end;
        if WinSetForeColor(120)>0 then begin end;
        RctSetRectangle(R, xmitte-xbreite,ymitte-ybreite,xbreite,ybreite);
        WinDrawRectangle(r,10);
        if bhighlight then Delay(idelaylen);
       end;
    1: begin
        if bhighlight then
        begin
         WinDrawChars(sTaste,length(sTaste), xmitte+30, ymitte-35);
         DoSound(1000,isoundlen);
        end;
        RctSetRectangle(R, xmitte+1,ymitte-ybreite,xbreite,ybreite);
        if WinSetForeColor(180)>0 then begin end;
        WinDrawRectangle(r,10);
        if bhighlight then Delay(idelaylen);
       end;
    2: begin
        if bhighlight then
        begin
         WinDrawChars(sTaste,length(sTaste), xmitte-45, ymitte+20);
         DoSound(1200,isoundlen);
        end;
        RctSetRectangle(R, xmitte-xbreite,ymitte+1,xbreite,ybreite);
        if WinSetForeColor(100)>0 then begin end;
        WinDrawRectangle(r,10);
        if bhighlight then Delay(idelaylen);
       end;
    3: begin
        if bhighlight then
        begin;
         WinDrawChars(sTaste,length(sTaste), xmitte+30, ymitte+20);
         DoSound(1400,isoundlen);
        end;
        RctSetRectangle(R, xmitte+1,ymitte+1,xbreite,ybreite);
        if WinSetForeColor(110)>0 then begin end;
        WinDrawRectangle(r,10);
        if bhighlight then Delay(idelaylen);
       end;
  end;

  // hier kein flush, sonst hakt es etwas wenn man die sequenz schnell wiederholt
  // da ja visu auch beim wiederholen für den getätigten klick durchlaufen wird
end;

// ----------------------------------------------------

procedure batteryupdate;
var sBatteryInfo:string;
begin
  sBatteryInfo:= 'Akkustatus: ' + GetBatteryInfo; // + ' / ' + inttostr(StartCount) + ' / ' + inttostr(PlayCount) + '         ';
  WinDrawChars(sBatteryInfo, length(sBatteryinfo), 1, 20);
end;

// ----------------------------------------------------

procedure StartScreen;
begin

      WinEraseRectangle(WorkRect, 1);

      WinDrawChars(sVersion, length(sVersion), iInfPos, 0);
      batteryupdate;
      //Akkustatus (erste Zeile) automatisch, trotzdem hier gleich anzeigen (programmstart)

      WinDrawChars(sstart, length(sstart), 16, 50);
      WinDrawChars(sanweisung1, length(sanweisung1), 16, 70);
      WinDrawChars(sanweisung2, length(sanweisung2), 16, 80);
      WinDrawChars(sanweisung3, length(sanweisung3), 16, 90);

end;

// ----------------------------------------------------

Procedure StartGame;
var i:integer;
    iTmp:integer;
    sDebug:string;
begin
  inc(PlayCount);

  // if not bFirst then
  //  if FrmAlert(dlgdebug3)=0 then begin end;

  WinEraseRectangle(WorkRect, 1);
  WinDrawChars(sVersion, length(sVersion), iInfPos, 0);

  if WinSetForeColor(255)>0 then begin end;
  WinDrawLine(xMitte,yMitte-yBreite,xMitte,yMitte+yBreite);
  WinDrawLine(xMitte-xBreite,yMitte,xMitte+xBreite,yMitte);

  for i:= 0 to 3 do
  begin
   visu(i,false);
  end;

  GameState:= gsStart;

  for i:= 0 to iMaxArray do
  begin
   // Verteilung zu analysieren... Zufällig scheint das nicht wirklich zu sein
   itmp:= random(39);
   wertearray[i]:= itmp div 10;
   sDebug:= sDebug + inttostr(itmp)+'/';
  end;
  // WinDrawChars(sDebug, length(sDebug), 0, 30); // Debug

  aktstart:= 0;
  aktstop:=  0;
  aktpos:=   0;
  aktlen:=   1;

  GameState:= gsRunPC;

  FlushEvents;
end;

// ----------------------------------------------------

Procedure HandleClick(iPos:Integer);
begin
  if GameState <> gsRunUser then exit;

  Visu(iPos, true);

  if WerteArray[aktPos] = iPos then
  begin
   if aktpos>=aktstop then
   begin
    WinDrawChars(sRichtig, length(sRichtig), iInfPos, 0);

    if ( (gamemode=gmEasy) and (aktlen >= iSeqLenEasy) ) or
       ( (gamemode=gmNormal) and (aktlen >= iSeqLenNormal) ) or
       ( (gamemode=gmHard) and (aktlen >= iSeqLenHard) ) then
    begin
     DoSound(600,50);
     DoSound(800,50);
     DoSound(1000,50);
     DoSound(1200,500);

     WinEraseRectangle(WorkRect, 1);

     WinDrawChars(sVersion, length(sVersion), iInfPos, 0);
     //Akkustatus (erste Zeile) automatisch

     WinDrawChars(swon1, length(swon1), 16, 40);
     WinDrawChars(swon2, length(swon2), 16, 50);
     WinDrawChars(swon3, length(swon3), 16, 60);

     WinDrawChars(swon4, length(swon4), 16, 80);
     WinDrawChars(swon5, length(swon5), 16, 90);
     WinDrawChars(swon6, length(swon6), 16, 100);


     gamestate:= gsWon;
    end
    else
    begin
     aktstart:= aktstop+1;
     aktlen:= aktlen+1;
     aktstop:= aktstart+aktlen-1;
     aktpos:= aktstart;

     gamestate:= gsRunPc;
    end;

    delay(1000);

   end
   else
   begin
    inc(aktpos);
   end;
  end
  else
  begin
   WinDrawChars(sFalsch, length(sFalsch), iInfPos, 0);

   DoSound(600,50);
   DoSound(500,50);
   DoSound(400,50);
   DoSound(300,500);

   WinEraseRectangle(WorkRect, 1);

   WinDrawChars(sVersion, length(sVersion), iInfPos, 0);
   //Akkustatus (erste Zeile) automatisch

   WinDrawChars(sloose, length(sloose), 16, 50);
   WinDrawChars(sanweisung1, length(sanweisung1), 16, 70);
   WinDrawChars(sanweisung2, length(sanweisung2), 16, 80);
   WinDrawChars(sanweisung3, length(sanweisung3), 16, 90);

   GameState:= gsLoose;
   exit;
  end;

  // kein FlushEvents !
end;

// ----------------------------------------------------

Function HandleEvent(var Event: EventType): Boolean;
var
  N: Integer;
  OldMenu: Pointer;
  PForm: FormPtr;

  CurX: Integer;
  CurY: Integer;

begin
  HandleEvent:=False;

  with Event do
  Case eType of
  // ----------
  frmLoadEvent:
    begin
      PForm:=FrmInitForm(data.frmLoad.FormID);
      FrmSetActiveForm(PForm); //Load the Form resource
      FrmSetEventHandlerNONE(PForm); //Is in Form.pas

      HandleEvent:= true;
    end;
  frmOpenEvent: //Main Form
    begin
      FrmDrawForm(FrmGetActiveForm);

      StartScreen;

      //StartGame(true);

      HandleEvent:= true;
    end;
  // ----------
  (*
  menuEvent:
    begin;
      Case Data.Menu.ItemID of
        MenuNewGame:  begin
                       if FrmAlert(DlgNewGame)=0 then begin
                        StartGame(false);
                       end;
                      end;
        MenuAbout:   begin
                       if FrmAlert(DlgInfo)=0 then begin
                        //
                       end;
                     end;
      end;
      HandleEvent:= true;
    end;
  *)
  // ----------
  penDownEvent:
    begin
      PenDown:=True;
      if InWorkRect(Event) then begin
        CurX := ScreenX;
        CurY := ScreenY;

        if (CurX < xMitte) then
        begin
          if CurY < yMitte then
            HandleClick(0)
          else
            HandleClick(2);
        end
        else
        begin
          if CurY < yMitte then
            HandleClick(1)
          else
            HandleClick(3);
        end;


        HandleEvent:= true;
      end;
    end;
  penUpEvent:
    begin
      if PenDown and InWorkRect(Event) then begin
        //
        HandleEvent:= true;
      end;
    end;
  penMoveEvent:
    if PenDown and InWorkRect(Event) then begin
      //
      HandleEvent:= true;
    end;
  keyDownEvent:
    begin
      lastbatteryupdate:= 0; // löst sofortigen refresh bei taste ein/aus
      // vchrPower kommt bei Tastenbetätigung
      // vchrLateWakeup kommt beim reaktivieren
      // vchrAutoOff kommt beim Timer aus

      if data.keydown.chr = vchrLateWakeup then
      begin
        inc(StartCount);

        DisplayFullScreenIntro(500);

        WinEraseRectangle(WorkRect, 1);

        FrmDrawForm(FrmGetActiveForm);

        gamestate:= gsStart;
        gamemode:= gmNormal;
        startscreen;

        FlushEvents;
      end;

      if (data.keydown.chr = vchrPowerOff) or
         (data.keydown.chr = vchrAutoOff) then
      begin
        // Achtung: hier nur mit Bedacht Code einfügen, sonst blockiert man ggf. den Standby, fatal!
        DisplayBlack;
      end;

    end;
  // ----------
  ctlSelectEvent: //Control button
    begin
      case Data.CtlEnter.ControlID of
        MainSButton: begin;
                        GameMode:= gmEasy;
                        StartGame;
                     end;
        MainNButton: begin;
                        GameMode:= gmNormal;
                        StartGame;
                     end;
        MainPButton: begin;
                        GameMode:= gmHard;
                        StartGame;
                     end;
      end;
      HandleEvent:= true;
    end;
  // ----------
  else
    HandleEvent:=False;
  end;
end;

// ----------------------------------------------------

procedure Main;
Var
  Event:  EventType;
  Error:  UInt16;
  DoStop: Boolean;
  i:      Integer;
  s:      String;
begin
  // if sndinit > 0 then exit;
  // SndPlaySystemSound(sndStartUp);

  // init zufallsgenerator
  Randomize;

  // init Variablen
  lastbatteryupdate:= 0;
  StartCount:= 0;
  PlayCount:= 0;

  // workrect init
  RctSetRectangle(WorkRect,0,16,160,110);
  FrmGotoForm(MainForm);
  WinDrawChars(sSchwierigkeit, length(sSchwierigkeit), 16, 125);

  LastBatteryupdate:=0;
  gamestate:= gsStart;
  gamemode:= gmNormal;
  // startscreen wird von formload aufgerufen
  // init der spielvariablen siehe startgame

  DoStop:= false;
  Repeat
    // Event über eigenen Eventhandler holen,
    // der filtert und führt eigenständig SysHandleEvent() aus
    EventHandlerGetEvent(false, 10, Event);

    if not MenuHandleEvent(MyMenu,Event,Error) then
    begin
    end;
    if not FrmDispatchEvent(Event) then
    begin
    end;
    if gamestate <> gsrunPC then
        if not HandleEvent(Event) then begin
        end;

    if gamestate=gsRunPC then
    begin
      WinDrawChars(sPC, length(sPC), iInfPos, 0);

      for i:= aktstart to aktstop do
        visu(wertearray[i], true);

      gamestate:= gsRunUser;
      WinDrawChars(sDu, length(sDu), iInfPos, 0);

      FlushEvents; // falls jemand
    end;

    if (gamestate <> gsrunpc) and (gamestate <> gsrunuser) then
    begin
      if abs(TimGetSeconds - lastbatteryupdate) >= 3 then
      begin
       lastBatteryUpdate:= TimGetSeconds;
       Batteryupdate;
      end;
    end;

  Until DoStop or (Event.eType=appStopEvent);
  if FrmGetActiveForm<>nil then begin
    FrmEraseForm(FrmGetActiveForm);
    FrmDeleteForm(FrmGetActiveForm);
  end;
end;

// ----------------------------------------------------

begin
  Main;
end.
